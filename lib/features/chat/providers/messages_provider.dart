import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../repositories/local_chat_repository.dart';
import '../../../core/network/websocket_manager.dart';
import '../../../core/network/websocket_service.dart';
import '../../../core/security/encryption_service.dart';
import '../services/chat_service.dart';

part 'messages_provider.g.dart';

@riverpod
class Messages extends _$Messages {
  Future<String?> _resolvePublicKey(String chatId, String? currentUserId) async {
    final localRepo = ref.read(localChatRepositoryProvider);
    var chat = await localRepo.getChat(chatId);
    if (chat != null && chat.peerPublicKey != null) {
      return chat.peerPublicKey;
    }

    try {
      final chatService = ref.read(chatServiceProvider);
      final remoteChats = await chatService.getChats();
      for (final chatData in remoteChats) {
        if (chatData['id'] == chatId && chatData['type'] == 'direct' && chatData['members'] != null) {
           final members = chatData['members'] as List;
           final peerMembers = currentUserId != null 
                ? members.where((m) => m['id'] != currentUserId).toList()
                : members;
           String? peerPublicKey;
           if (peerMembers.isNotEmpty) {
             peerPublicKey = peerMembers.first['identity_key'];
           } else if (members.isNotEmpty) {
             peerPublicKey = members.first['identity_key'];
           }
           if (peerPublicKey != null && chat != null) {
             final updatedChat = ChatModel(
               id: chat.id,
               name: chat.name,
               lastMessage: chat.lastMessage,
               lastMessageTime: chat.lastMessageTime,
               unreadCount: chat.unreadCount,
               peerPublicKey: peerPublicKey,
             );
             await localRepo.saveChat(updatedChat);
           }
           return peerPublicKey;
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  FutureOr<List<MessageModel>> build(String chatId) async {
    final localRepo = ref.read(localChatRepositoryProvider);
    final storage = ref.read(secureStorageServiceProvider);
    
    // Subscribe to real-time WebSocket messages
    final wsService = ref.watch(webSocketServiceProvider);
    
    final sub = wsService.messages.listen((payload) async {
      if (payload['type'] == 'message') {
         final data = payload['payload'];
         if (data['chat_id'] == chatId) {
           
           // Extract current user ID
           final token = await storage.getAccessToken();
           String? currentUserId;
           if (token != null) {
             final parts = token.split('.');
             if (parts.length == 3) {
               try {
                 String normalized = base64Url.normalize(parts[1]);
                 switch (normalized.length % 4) {
                   case 2: normalized += '=='; break;
                   case 3: normalized += '='; break;
                 }
                 final decoded = utf8.decode(base64Url.decode(normalized));
                 final map = jsonDecode(decoded);
                 currentUserId = map['user_id'] ?? map['sub'];
               } catch (_) {}
             }
           }
           
           String decryptedContent = 'Secure message';
           String? peerPublicKey = await _resolvePublicKey(chatId, currentUserId);
           
           if (peerPublicKey != null) {
             try {
               final encryptionService = ref.read(encryptionServiceProvider);
               decryptedContent = await encryptionService.decryptMessage(data['ciphertext'], peerPublicKey);
             } catch (e) {
               decryptedContent = 'Secure message';
             }
           } else {
             // Fallback if no public key is found
             decryptedContent = data['ciphertext'] ?? 'Secure message';
           }

           final currentMessages = state.value ?? [];
           final isMe = currentUserId != null && data['sender_id'] == currentUserId;
           
           // Check if we already have this message from optimistic UI
           final existingIdx = currentMessages.indexWhere((m) => 
               m.id == data['id'] || 
               (isMe && m.senderId == 'me' && m.content == decryptedContent)
           );

           final msg = MessageModel(
             id: data['id'],
             chatId: data['chat_id'],
             senderId: isMe ? 'me' : data['sender_id'],
             content: decryptedContent,
             timestamp: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
           );

           if (existingIdx != -1) {
             await localRepo.deleteMessage(currentMessages[existingIdx].id);
             await localRepo.saveMessage(msg);
             final newMessages = List<MessageModel>.from(currentMessages);
             newMessages[existingIdx] = msg;
             state = AsyncData(newMessages);
             return;
           }

           await localRepo.saveMessage(msg);
           
           // Update UI instantly
           state = AsyncData([msg, ...currentMessages]);
         }
      }
    });
    
    ref.onDispose(() => sub.cancel());

    // Initial load from SQLite
    final initialMessages = await localRepo.getMessagesForChat(chatId);
    
    // Trigger background sync
    _syncMessages(chatId);
    
    return initialMessages;
  }

  Future<void> _syncMessages(String chatId) async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final localRepo = ref.read(localChatRepositoryProvider);
      final encryptionService = ref.read(encryptionServiceProvider);

      final remoteMessages = await chatService.getMessages(chatId);

      bool hasUpdates = false;

      final storage = ref.read(secureStorageServiceProvider);
      final token = await storage.getAccessToken();
      String? currentUserId;
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          try {
            String normalized = base64Url.normalize(parts[1]);
            switch (normalized.length % 4) {
              case 2: normalized += '=='; break;
              case 3: normalized += '='; break;
            }
            final decoded = utf8.decode(base64Url.decode(normalized));
            final map = jsonDecode(decoded);
            currentUserId = map['user_id'] ?? map['sub'];
          } catch (_) {}
        }
      }

      String? peerPublicKey = await _resolvePublicKey(chatId, currentUserId);

      for (final data in remoteMessages.reversed) {
        // Skip if already in DB
        final existingMsg = await localRepo.getMessage(data['id']);
        if (existingMsg != null) continue;

        String decryptedContent = 'Secure message';
        if (peerPublicKey != null) {
          try {
            decryptedContent = await encryptionService.decryptMessage(data['ciphertext'], peerPublicKey);
          } catch (e) {
            decryptedContent = 'Secure message';
          }
        } else {
           decryptedContent = data['ciphertext'] ?? 'Secure message';
        }

        final isMe = currentUserId != null && data['sender_id'] == currentUserId;

        final msg = MessageModel(
          id: data['id'],
          chatId: data['chat_id'],
          senderId: isMe ? 'me' : data['sender_id'],
          content: decryptedContent,
          timestamp: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
        );
        
        await localRepo.saveMessage(msg);
        hasUpdates = true;
      }

      if (hasUpdates) {
        state = AsyncData(await localRepo.getMessagesForChat(chatId));
      }
    } catch (e) {
      // Background sync failed, ignore
    }
  }

  Future<void> sendMessage(String content) async {
    final storage = ref.read(secureStorageServiceProvider);
    final token = await storage.getAccessToken();
    String? currentUserId;
    if (token != null) {
      final parts = token.split('.');
      if (parts.length == 3) {
        try {
          String normalized = base64Url.normalize(parts[1]);
          switch (normalized.length % 4) {
            case 2: normalized += '=='; break;
            case 3: normalized += '='; break;
          }
          final decoded = utf8.decode(base64Url.decode(normalized));
          currentUserId = jsonDecode(decoded)['user_id'];
        } catch (_) {}
      }
    }

    String? peerPublicKey = await _resolvePublicKey(chatId, currentUserId);
    if (peerPublicKey == null) {
      throw Exception('Cannot send message: peer public key is not available.');
    }

    String ciphertext;
    try {
      final encryptionService = ref.read(encryptionServiceProvider);
      ciphertext = await encryptionService.encryptMessage(content, peerPublicKey);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }

    final senderId = 'me'; // Fixed to 'me' for visual grouping
    final msgId = const Uuid().v4();

    // 1. Optimistic UI update and save locally (save plaintext)
    final msg = MessageModel(
      id: msgId,
      chatId: chatId,
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
    );
    
    final localRepo = ref.read(localChatRepositoryProvider);
    await localRepo.saveMessage(msg);
    
    final currentMessages = state.value ?? [];
    state = AsyncData([msg, ...currentMessages]);
    
    // 2. Transmit via WebSocket
    ref.read(webSocketManagerProvider.notifier).sendMessage({
      'type': 'message',
      'payload': {
        'id': msg.id,
        'chat_id': msg.chatId,
        'sender_id': msg.senderId, // Wait, backend ignores this and uses current user ID!
        'ciphertext': ciphertext,
        'iv': '', // IV is prepended to ciphertext in Dart cryptography package
        'message_type': 'text'
      }
    });
  }
}
