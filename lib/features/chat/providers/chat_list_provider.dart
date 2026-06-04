import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/websocket_service.dart';
import 'dart:async';
import 'dart:developer' as developer;

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/chat_message_payload.dart';
import '../repositories/local_chat_repository.dart';
import '../services/chat_service.dart';
import '../../../core/security/encryption_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/database_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

part 'chat_list_provider.g.dart';

@riverpod
class ChatList extends _$ChatList {
  @override
  FutureOr<List<ChatModel>> build() async {
    // 1. Instantly read local cached chats for optimistic UI
    final localRepo = ref.read(localChatRepositoryProvider);
    final localChats = await localRepo.getChats();

    // 2. Trigger background network sync
    syncChats();

    final storage = ref.read(secureStorageServiceProvider);
    final token = await storage.getAccessToken();
    String? currentUserId;
    if (token != null) {
      final parts = token.split('.');
      if (parts.length == 3) {
        try {
          String normalized = base64Url.normalize(parts[1]);
          switch (normalized.length % 4) {
            case 2:
              normalized += '==';
              break;
            case 3:
              normalized += '=';
              break;
          }
          final decoded = utf8.decode(base64Url.decode(normalized));
          currentUserId = jsonDecode(decoded)['user_id'];
        } catch (_) {}
      }
    }

    final wsService = ref.watch(webSocketServiceProvider);
    final sub = wsService.messages.listen((payload) async {
      if (payload['type'] == 'message') {
        final data = payload['payload'];
        if (data != null) {
          final isMe = currentUserId != null && data['sender_id'] == currentUserId;
          // Only save to messages if we can parse it (we don't need to decrypt it to just let it expire)
          final msg = MessageModel(
            id: data['id'],
            chatId: data['chat_id'],
            senderId: isMe ? 'me' : data['sender_id'],
            content: data['ciphertext'] ?? '',
            timestamp: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
            status: data['status'] ?? 'sent',
            expiresAt: data['expires_at'] != null ? DateTime.parse(data['expires_at']) : null,
          );
          await localRepo.saveMessage(msg);
        }
        syncChats();
      } else if (payload['type'] == 'message_delete') {
        final data = payload['payload'];
        if (data != null && data['message_ids'] != null) {
          final ids = List<String>.from(data['message_ids']);
          for (final id in ids) {
            await localRepo.deleteMessage(id);
          }
        }
        syncChats();
      } else if (payload['type'] == 'online' || payload['type'] == 'offline') {
        final data = payload['payload'];
        if (data != null && data['user_id'] != null) {
          final userId = data['user_id'] as String;
          final isOnline = payload['type'] == 'online';

          final dbService = ref.read(databaseServiceProvider);
          final db = await dbService.database;
          await db.update(
            'chats',
            {
              'is_online': isOnline ? 1 : 0,
              'last_seen': isOnline ? null : DateTime.now().millisecondsSinceEpoch,
            },
            where: 'peer_id = ?',
            whereArgs: [userId],
          );

          final localChats = state.value ?? [];
          bool updated = false;
          final newChats = localChats.map((chat) {
            if (chat.peerId == userId) {
              updated = true;
              return chat.copyWith(
                isOnline: isOnline,
                lastSeen: isOnline ? null : DateTime.now(),
              );
            }
            return chat;
          }).toList();

          if (updated) {
            state = AsyncData(newChats);
          }
        }
      }
    });

    int syncCounter = 0;
    final timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final deleted = await localRepo.deleteExpiredMessages();
      if (deleted) {
        syncChats();
        syncCounter = 0;
      } else {
        syncCounter++;
        if (syncCounter >= 15) {
          syncChats();
          syncCounter = 0;
        }
      }
    });

    ref.onDispose(() {
      sub.cancel();
      timer.cancel();
    });

    return localChats;
  }

  Future<void> syncChats() async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final localRepo = ref.read(localChatRepositoryProvider);
      final encryptionService = ref.read(encryptionServiceProvider);

      final storage = ref.read(secureStorageServiceProvider);
      final token = await storage.getAccessToken();
      String? currentUserId;
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          try {
            String normalized = base64Url.normalize(parts[1]);
            switch (normalized.length % 4) {
              case 1:
                break; // invalid
              case 2:
                normalized += '==';
                break;
              case 3:
                normalized += '=';
                break;
            }
            final payload = utf8.decode(base64Url.decode(normalized));
            final map = jsonDecode(payload);
            currentUserId = map['user_id'] ?? map['sub'];
          } catch (e) {
            // Ignore token parsing errors
          }
        }
      }

      final remoteChats = await chatService.getChats();
      
      final prefs = await SharedPreferences.getInstance();
      final deletedChatsRaw = prefs.getStringList('deleted_chats_$currentUserId') ?? [];
      final deletedChats = <String, DateTime>{};
      for (final raw in deletedChatsRaw) {
        final parts = raw.split('|');
        if (parts.length == 2) {
          deletedChats[parts[0]] = DateTime.fromMillisecondsSinceEpoch(int.tryParse(parts[1]) ?? 0);
        }
      }

      // Parse remote chats and sync to SQLite
      for (final chatData in remoteChats) {
        String name = chatData['name'] ?? 'Unknown Chat';
        String? peerPublicKey;
        bool isOnline = false;
        DateTime? lastSeen;
        String? peerId;
        String? avatarUrl;
        String? bio;

        // For direct chats, try to extract the member's username and public key
        if (chatData['type'] == 'direct' && chatData['members'] != null) {
          final members = chatData['members'] as List;
          final peerMembers = currentUserId != null
              ? members.where((m) => m['id'] != currentUserId).toList()
              : members;

          if (peerMembers.isEmpty && members.length <= 1) {
            // The other person left this direct chat. It is dead.
            await localRepo.deleteChat(chatData['id']);
            continue; // Skip saving this chat
          }

          if (peerMembers.isNotEmpty) {
            name = peerMembers.first['username'] ?? 'User';
            peerPublicKey = peerMembers.first['identity_key'];
            peerId = peerMembers.first['id'];
            avatarUrl = peerMembers.first['avatar_url'];
            bio = peerMembers.first['bio'];
            if (peerMembers.first['last_seen'] != null) {
              lastSeen = DateTime.tryParse(peerMembers.first['last_seen']);
            }
          } else if (members.isNotEmpty) {
            name = members.first['username'] ?? 'User';
            peerPublicKey = members.first['identity_key'];
            peerId = members.first['id'];
            avatarUrl = members.first['avatar_url'];
            bio = members.first['bio'];
            if (members.first['last_seen'] != null) {
              lastSeen = DateTime.tryParse(members.first['last_seen']);
            }
          }
          
          if (peerId != null) {
            final localChats = await localRepo.getChats();
            final existingPeerChat = localChats.where((c) => c.peerId == peerId).firstOrNull;
            if (existingPeerChat != null) {
              isOnline = existingPeerChat.isOnline;
              lastSeen = existingPeerChat.lastSeen ?? lastSeen;
            }
          }
        }

        final lastMsg = chatData['last_message'];
        String lastMessageText = 'No messages yet';
        DateTime lastMessageTime =
            lastMsg != null && lastMsg['created_at'] != null
            ? DateTime.parse(lastMsg['created_at'])
            : DateTime.parse(chatData['created_at']);

        bool useLocalLatest = false;
        if (lastMsg != null) {
          final localMsg = await localRepo.getMessage(lastMsg['id']);
          if (localMsg != null && localMsg.isDeleted) {
            useLocalLatest = true;
          } else if (lastMsg['expires_at'] != null) {
            final expiresAt = DateTime.parse(lastMsg['expires_at']);
            if (DateTime.now().isAfter(expiresAt)) {
              useLocalLatest = true;
            }
          }
        }

        if (useLocalLatest) {
          final latestLocal = await localRepo.getMessagesForChat(
            chatData['id'],
            limit: 1,
          );
          if (latestLocal.isNotEmpty) {
            final latest = latestLocal.first;
            lastMessageTime = latest.timestamp;
            if (latest.messageType == 'image') {
              lastMessageText = '📷 Image';
            } else if (latest.messageType == 'video') {
              lastMessageText = '🎥 Video';
            } else if (latest.messageType == 'document') {
              lastMessageText = '📄 Document';
            } else if (latest.messageType == 'audio') {
              lastMessageText = '🎵 Audio';
            } else {
              try {
                final payload = ChatMessagePayload.fromJson(
                  jsonDecode(latest.content),
                );
                lastMessageText = payload.content ?? 'Secure message';
              } catch (_) {
                lastMessageText = latest.content;
              }
            }
          } else {
            lastMessageText = 'No messages yet';
            lastMessageTime = DateTime.parse(chatData['created_at']);
          }
        } else if (lastMsg != null && lastMsg['ciphertext'] != null) {
          if (peerPublicKey != null) {
            try {
              final decrypted = await encryptionService.decryptMessage(
                lastMsg['ciphertext'],
                peerPublicKey,
              );
              try {
                final payload = ChatMessagePayload.fromJson(
                  jsonDecode(decrypted),
                );
                if (payload.type == 'image') {
                  lastMessageText = '📷 Image';
                } else if (payload.type == 'video') {
                  lastMessageText = '🎥 Video';
                } else if (payload.type == 'document') {
                  lastMessageText = '📄 Document';
                } else if (payload.type == 'audio') {
                  lastMessageText = '🎵 Audio';
                } else {
                  lastMessageText = payload.content ?? 'Secure message';
                }
              } catch (_) {
                lastMessageText = decrypted;
              }
            } catch (e) {
              lastMessageText = 'Secure message';
            }
          } else {
            lastMessageText = 'Secure message';
          }
        }

        // Preserve local real-time presence if it exists and contradicts stale server data
        final existingChat = await localRepo.getChat(chatData['id']);

        DateTime? deletedAt = existingChat?.deletedAt;
        
        final prefsDeletedAt = deletedChats[chatData['id']];
        if (prefsDeletedAt != null && (deletedAt == null || prefsDeletedAt.isAfter(deletedAt))) {
          deletedAt = prefsDeletedAt;
        }

        if (deletedAt != null && lastMessageTime.isAfter(deletedAt)) {
          deletedAt = null;
        } else if (deletedAt != null) {
          await localRepo.deleteChat(chatData['id']);
          continue;
        }
        
        if (existingChat != null) {
          // If we already saw them online locally via WS, and server says offline, trust WS
          if (existingChat.isOnline && !isOnline) {
            isOnline = true;
            lastSeen = existingChat.lastSeen;
          } else if (!existingChat.isOnline && !isOnline) {
            // Keep the most recent lastSeen
            if (existingChat.lastSeen != null &&
                (lastSeen == null ||
                    existingChat.lastSeen!.isAfter(lastSeen))) {
              lastSeen = existingChat.lastSeen;
            }
          }
        }

        final chat = ChatModel(
          id: chatData['id'],
          name: name,
          lastMessage: lastMessageText,
          lastMessageTime: lastMessageTime,
          unreadCount: chatData['unread_count'] ?? 0,
          peerPublicKey: peerPublicKey,
          isOnline: isOnline,
          lastSeen: lastSeen,
          peerId: peerId,
          avatarUrl: avatarUrl,
          bio: bio,
          deletedAt: deletedAt,
          isSecret: chatData['is_secret'] ?? false,
          messageTtl: chatData['message_ttl'],
        );

        await localRepo.saveChat(chat);
      }

      // 3. Re-read from local DB to update the UI with fresh synced data
      final updatedChats = await localRepo.getChats();
      state = AsyncData(updatedChats);
    } catch (e) {
      developer.log('Failed to sync chats from server', error: e);
      // We don't alter the state here so it fails silently while keeping the local cache visible
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      final localRepo = ref.read(localChatRepositoryProvider);

      final chat = await localRepo.getChat(chatId);
      if (chat != null) {
        if (chat.peerId == null || chat.isSecret) {
          // Group chat or Secret Direct chat - leave it
          final chatService = ref.read(chatServiceProvider);
          await chatService.deleteChat(chatId);
          await localRepo.deleteChat(chatId);
        } else {
          // Normal Direct chat - soft delete locally
          final deletedTime = DateTime.now();
          final updatedChat = chat.copyWith(deletedAt: deletedTime);
          await localRepo.saveChat(updatedChat);
          
          final storage = ref.read(secureStorageServiceProvider);
          final token = await storage.getAccessToken();
          if (token != null) {
            try {
              final parts = token.split('.');
              String normalized = base64Url.normalize(parts[1]);
              switch (normalized.length % 4) {
                case 2: normalized += '=='; break;
                case 3: normalized += '='; break;
              }
              final map = jsonDecode(utf8.decode(base64Url.decode(normalized)));
              final uid = map['user_id'] ?? map['sub'];
              if (uid != null) {
                final prefs = await SharedPreferences.getInstance();
                final dChats = prefs.getStringList('deleted_chats_$uid') ?? [];
                dChats.add('$chatId|${deletedTime.millisecondsSinceEpoch}');
                await prefs.setStringList('deleted_chats_$uid', dChats);
              }
            } catch (_) {}
          }
        }
      }

      // Delete local messages
      final dbService = ref.read(databaseServiceProvider);
      final db = await dbService.database;
      await db.delete('messages', where: 'chat_id = ?', whereArgs: [chatId]);

      // Update UI
      final currentChats = state.value ?? [];
      state = AsyncData(currentChats.where((c) => c.id != chatId).toList());
    } catch (e) {
      developer.log('Failed to delete chat locally', error: e);
      rethrow;
    }
  }
}
