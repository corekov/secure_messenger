import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/websocket_service.dart';
import 'dart:developer' as developer;

import '../models/chat_model.dart';
import '../repositories/local_chat_repository.dart';
import '../services/chat_service.dart';
import '../../../core/security/encryption_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'dart:convert';

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
    
    // 3. Listen to real-time messages to update "Last Message", unread counts, and presence
    final wsService = ref.watch(webSocketServiceProvider);
    final sub = wsService.messages.listen((payload) async {
      if (payload['type'] == 'message') {
        syncChats();
      } else if (payload['type'] == 'online' || payload['type'] == 'offline') {
        final data = payload['payload'];
        if (data != null && data['user_id'] != null) {
          final userId = data['user_id'] as String;
          final isOnline = payload['type'] == 'online';
          
          final localChats = state.value ?? [];
          bool updated = false;
          final newChats = localChats.map((chat) {
            if (chat.peerId == userId) {
              updated = true;
              final updatedChat = ChatModel(
                id: chat.id,
                name: chat.name,
                lastMessage: chat.lastMessage,
                lastMessageTime: chat.lastMessageTime,
                unreadCount: chat.unreadCount,
                peerPublicKey: chat.peerPublicKey,
                isOnline: isOnline,
                lastSeen: isOnline ? null : DateTime.now(),
                peerId: chat.peerId,
              );
              localRepo.saveChat(updatedChat);
              return updatedChat;
            }
            return chat;
          }).toList();
          
          if (updated) {
            state = AsyncData(newChats);
          }
        }
      }
    });
    
    ref.onDispose(() => sub.cancel());

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
              case 1: break; // invalid
              case 2: normalized += '=='; break;
              case 3: normalized += '='; break;
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
      
      // Parse remote chats and sync to SQLite
      for (final chatData in remoteChats) {
        String name = chatData['name'] ?? 'Unknown Chat';
        String? peerPublicKey;
        bool isOnline = false;
        DateTime? lastSeen;
        String? peerId;
        
        // For direct chats, try to extract the member's username and public key
        if (chatData['type'] == 'direct' && chatData['members'] != null) {
           final members = chatData['members'] as List;
           final peerMembers = currentUserId != null 
                ? members.where((m) => m['id'] != currentUserId).toList()
                : members;
           if (peerMembers.isNotEmpty) {
             name = peerMembers.first['username'] ?? 'User';
             peerPublicKey = peerMembers.first['identity_key'];
             peerId = peerMembers.first['id'];
             isOnline = peerMembers.first['is_active'] ?? false;
             if (peerMembers.first['last_seen'] != null) {
               lastSeen = DateTime.tryParse(peerMembers.first['last_seen']);
             }
           } else if (members.isNotEmpty) {
             name = members.first['username'] ?? 'User';
             peerPublicKey = members.first['identity_key'];
             peerId = members.first['id'];
             isOnline = members.first['is_active'] ?? false;
             if (members.first['last_seen'] != null) {
               lastSeen = DateTime.tryParse(members.first['last_seen']);
             }
           }
        }
        
        final lastMsg = chatData['last_message'];
        String lastMessageText = 'No messages yet';
        
        if (lastMsg != null && lastMsg['ciphertext'] != null) {
          if (peerPublicKey != null) {
            try {
              lastMessageText = await encryptionService.decryptMessage(lastMsg['ciphertext'], peerPublicKey);
            } catch (e) {
              lastMessageText = 'Secure message';
            }
          } else {
            lastMessageText = 'Secure message';
          }
        }
        
        final DateTime lastMessageTime = lastMsg != null && lastMsg['created_at'] != null 
            ? DateTime.parse(lastMsg['created_at']) 
            : DateTime.parse(chatData['created_at']);
        
        // Preserve local real-time presence if it exists and contradicts stale server data
        final currentLocalChats = state.value ?? [];
        final existingChat = currentLocalChats.where((c) => c.id == chatData['id']).firstOrNull;
        
        if (existingChat != null) {
          // If we already saw them online locally via WS, and server says offline, trust WS
          if (existingChat.isOnline && !isOnline) {
            isOnline = true;
            lastSeen = existingChat.lastSeen;
          } else if (!existingChat.isOnline && !isOnline) {
            // Keep the most recent lastSeen
            if (existingChat.lastSeen != null && (lastSeen == null || existingChat.lastSeen!.isAfter(lastSeen))) {
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
      final chatService = ref.read(chatServiceProvider);
      final localRepo = ref.read(localChatRepositoryProvider);
      
      // Delete remote
      await chatService.deleteChat(chatId);
      // Delete local
      await localRepo.deleteChat(chatId);
      
      // Update UI
      final currentChats = state.value ?? [];
      state = AsyncData(currentChats.where((c) => c.id != chatId).toList());
    } catch (e) {
      developer.log('Failed to delete chat', error: e);
      rethrow;
    }
  }
}
