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
import '../providers/file_service_provider.dart';
import '../models/chat_message_payload.dart';

part 'messages_provider.g.dart';

@riverpod
class Messages extends _$Messages {
  Future<String?> _resolvePublicKey(
    String chatId,
    String? currentUserId,
  ) async {
    final localRepo = ref.read(localChatRepositoryProvider);
    var chat = await localRepo.getChat(chatId);
    if (chat != null && chat.peerPublicKey != null) {
      return chat.peerPublicKey;
    }

    try {
      final chatService = ref.read(chatServiceProvider);
      final remoteChats = await chatService.getChats();
      for (final chatData in remoteChats) {
        if (chatData['id'] == chatId &&
            chatData['type'] == 'direct' &&
            chatData['members'] != null) {
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
                  case 2:
                    normalized += '==';
                    break;
                  case 3:
                    normalized += '=';
                    break;
                }
                final decoded = utf8.decode(base64Url.decode(normalized));
                final map = jsonDecode(decoded);
                currentUserId = map['user_id'] ?? map['sub'];
              } catch (_) {}
            }
          }

          String decryptedContent = 'Secure message';
          String? peerPublicKey = await _resolvePublicKey(
            chatId,
            currentUserId,
          );

          if (peerPublicKey != null) {
            try {
              final encryptionService = ref.read(encryptionServiceProvider);
              decryptedContent = await encryptionService.decryptMessage(
                data['ciphertext'],
                peerPublicKey,
              );
            } catch (e) {
              decryptedContent = 'Secure message';
            }
          } else {
            // Fallback if no public key is found
            decryptedContent = data['ciphertext'] ?? 'Secure message';
          }

          final currentMessages = state.value ?? [];
          final isMe =
              currentUserId != null && data['sender_id'] == currentUserId;

          MessageModel msg;
          try {
            final map = jsonDecode(decryptedContent);
            final payload = ChatMessagePayload.fromJson(map);
            msg = MessageModel(
              id: data['id'],
              chatId: data['chat_id'],
              senderId: isMe ? 'me' : data['sender_id'],
              content: decryptedContent,
              timestamp: data['created_at'] != null
                  ? DateTime.parse(data['created_at'])
                  : DateTime.now(),
              messageType: payload.type,
              fileId: payload.fileId,
              fileName: payload.fileName,
              fileSize: payload.fileSize,
              status: data['status'] ?? 'sent',
            );
          } catch (_) {
            msg = MessageModel(
              id: data['id'],
              chatId: data['chat_id'],
              senderId: isMe ? 'me' : data['sender_id'],
              content: decryptedContent,
              timestamp: data['created_at'] != null
                  ? DateTime.parse(data['created_at'])
                  : DateTime.now(),
              status: data['status'] ?? 'sent',
            );
          }

          // Auto-download logic
          if (!isMe &&
              msg.fileId != null &&
              msg.localFilePath == null &&
              (msg.messageType == 'image' || msg.messageType == 'video') &&
              (msg.fileSize ?? 0) < 15 * 1024 * 1024) {
            
            try {
              final payload = ChatMessagePayload.fromJson(jsonDecode(msg.content));
              if (payload.fileKey != null && payload.fileName != null) {
                final fileService = ref.read(fileServiceProvider);
                final localPath = await fileService.downloadAndDecryptFile(
                    msg.fileId!, payload.fileName!, payload.fileKey!);
                
                msg = MessageModel(
                  id: msg.id,
                  chatId: msg.chatId,
                  senderId: msg.senderId,
                  content: msg.content,
                  timestamp: msg.timestamp,
                  messageType: msg.messageType,
                  fileId: msg.fileId,
                  fileName: msg.fileName,
                  fileSize: msg.fileSize,
                  localFilePath: localPath,
                );
              }
            } catch (_) {}
          }

          // Check if we already have this message from optimistic UI
          final existingIdx = currentMessages.indexWhere(
            (m) =>
                m.id == data['id'] ||
                (isMe && m.senderId == 'me' && m.content == decryptedContent),
          );

          if (existingIdx != -1) {
            final oldMsg = currentMessages[existingIdx];
            
            // Preserve local file properties that the backend doesn't know about
            if (msg.localFilePath == null && oldMsg.localFilePath != null) {
              msg = MessageModel(
                id: msg.id,
                chatId: msg.chatId,
                senderId: msg.senderId,
                content: msg.content,
                timestamp: msg.timestamp,
                messageType: msg.messageType,
                fileId: msg.fileId ?? oldMsg.fileId,
                fileName: msg.fileName ?? oldMsg.fileName,
                fileSize: msg.fileSize ?? oldMsg.fileSize,
                localFilePath: oldMsg.localFilePath,
                status: data['status'] ?? 'sent',
              );
            }

            await localRepo.deleteMessage(oldMsg.id);
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
      } else if (payload['type'] == 'message_read') {
        final data = payload['payload'];
        if (data['chat_id'] == chatId) {
          final readerId = data['reader_id'];
          
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

          if (readerId != currentUserId) {
            // Mark all my delivered/sent messages as read
            final currentMessages = state.value ?? [];
            bool updated = false;
            final newMessages = currentMessages.map((m) {
              if (m.senderId == 'me' && m.status != 'read') {
                updated = true;
                final newM = MessageModel(
                  id: m.id,
                  chatId: m.chatId,
                  senderId: m.senderId,
                  content: m.content,
                  timestamp: m.timestamp,
                  messageType: m.messageType,
                  fileId: m.fileId,
                  fileName: m.fileName,
                  fileSize: m.fileSize,
                  localFilePath: m.localFilePath,
                  status: 'read',
                );
                localRepo.saveMessage(newM);
                return newM;
              }
              return m;
            }).toList();
            if (updated) state = AsyncData(newMessages);
          }
        }
      }
    });

    ref.onDispose(() => sub.cancel());

    // Initial load from SQLite
    final initialMessages = await localRepo.getMessagesForChat(chatId);

    // Trigger background sync
    _syncMessages(chatId);
    
    // Notify peer we read their messages
    ref.read(webSocketManagerProvider.notifier).sendMessage({
      'type': 'message_read',
      'payload': {'chat_id': chatId},
    });

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
              case 2:
                normalized += '==';
                break;
              case 3:
                normalized += '=';
                break;
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
            decryptedContent = await encryptionService.decryptMessage(
              data['ciphertext'],
              peerPublicKey,
            );
          } catch (e) {
            decryptedContent = 'Secure message';
          }
        } else {
          decryptedContent = data['ciphertext'] ?? 'Secure message';
        }

        final isMe =
            currentUserId != null && data['sender_id'] == currentUserId;

        MessageModel msg;
        try {
          final map = jsonDecode(decryptedContent);
          final payload = ChatMessagePayload.fromJson(map);
          msg = MessageModel(
            id: data['id'],
            chatId: data['chat_id'],
            senderId: isMe ? 'me' : data['sender_id'],
            content: decryptedContent,
            timestamp: data['created_at'] != null
                ? DateTime.parse(data['created_at'])
                : DateTime.now(),
            messageType: payload.type,
            fileId: payload.fileId,
            fileName: payload.fileName,
            fileSize: payload.fileSize,
            status: data['status'] ?? 'sent',
          );
        } catch (_) {
          msg = MessageModel(
            id: data['id'],
            chatId: data['chat_id'],
            senderId: isMe ? 'me' : data['sender_id'],
            content: decryptedContent,
            timestamp: data['created_at'] != null
                ? DateTime.parse(data['created_at'])
                : DateTime.now(),
            status: data['status'] ?? 'sent',
          );
        }

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

    String? peerPublicKey = await _resolvePublicKey(chatId, currentUserId);
    if (peerPublicKey == null) {
      throw Exception('Cannot send message: peer public key is not available.');
    }

    String ciphertext;
    try {
      final encryptionService = ref.read(encryptionServiceProvider);
      ciphertext = await encryptionService.encryptMessage(
        content,
        peerPublicKey,
      );
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
      status: 'sending',
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
        'sender_id': msg
            .senderId, // Wait, backend ignores this and uses current user ID!
        'ciphertext': ciphertext,
        'iv': '', // IV is prepended to ciphertext in Dart cryptography package
        'message_type': 'text',
      },
    });

    // Check for timeout
    Future.delayed(const Duration(seconds: 10), () async {
      final currentMsg = await localRepo.getMessage(msg.id);
      if (currentMsg != null && currentMsg.status == 'sending') {
        final errorMsg = MessageModel(
          id: currentMsg.id,
          chatId: currentMsg.chatId,
          senderId: currentMsg.senderId,
          content: currentMsg.content,
          timestamp: currentMsg.timestamp,
          messageType: currentMsg.messageType,
          fileId: currentMsg.fileId,
          fileName: currentMsg.fileName,
          fileSize: currentMsg.fileSize,
          localFilePath: currentMsg.localFilePath,
          status: 'error',
        );
        await localRepo.saveMessage(errorMsg);
        final list = state.value ?? [];
        final idx = list.indexWhere((m) => m.id == currentMsg.id);
        if (idx != -1) {
          final updated = List<MessageModel>.from(list);
          updated[idx] = errorMsg;
          state = AsyncData(updated);
        }
      }
    });
  }

  Future<void> sendFileMessage({
    required String filePath,
    required String messageType,
    required String fileName,
    required String mimeType,
    required int fileSize,
  }) async {
    final fileService = ref.read(fileServiceProvider);
    
    // 1. Generate key and encrypt
    final fileKey = await fileService.generateSymmetricKey();
    final encryptedPath = await fileService.encryptFile(filePath, fileKey);
    
    // 2. Upload file
    final fileId = await fileService.uploadEncryptedFile(encryptedPath);
    
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

    final payload = ChatMessagePayload(
      type: messageType,
      content: fileName,
      fileId: fileId,
      fileKey: fileKey,
      fileName: fileName,
      fileMimeType: mimeType,
      fileSize: fileSize,
    );
    final jsonPayload = jsonEncode(payload.toJson());

    String ciphertext;
    try {
      final encryptionService = ref.read(encryptionServiceProvider);
      ciphertext = await encryptionService.encryptMessage(jsonPayload, peerPublicKey);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }

    final msgId = const Uuid().v4();
    final msg = MessageModel(
      id: msgId,
      chatId: chatId,
      senderId: 'me',
      content: jsonPayload,
      timestamp: DateTime.now(),
      messageType: messageType,
      fileId: fileId,
      fileName: fileName,
      fileSize: fileSize,
      localFilePath: filePath,
      status: 'sending',
    );

    final localRepo = ref.read(localChatRepositoryProvider);
    await localRepo.saveMessage(msg);

    final currentMessages = state.value ?? [];
    state = AsyncData([msg, ...currentMessages]);

    ref.read(webSocketManagerProvider.notifier).sendMessage({
      'type': 'message',
      'payload': {
        'id': msg.id,
        'chat_id': msg.chatId,
        'sender_id': 'me',
        'ciphertext': ciphertext,
        'iv': '',
        'message_type': messageType,
        'file_id': fileId,
      },
    });

    // Timeout
    Future.delayed(const Duration(seconds: 10), () async {
      final currentMsg = await localRepo.getMessage(msg.id);
      if (currentMsg != null && currentMsg.status == 'sending') {
        final errorMsg = MessageModel(
          id: currentMsg.id,
          chatId: currentMsg.chatId,
          senderId: currentMsg.senderId,
          content: currentMsg.content,
          timestamp: currentMsg.timestamp,
          messageType: currentMsg.messageType,
          fileId: currentMsg.fileId,
          fileName: currentMsg.fileName,
          fileSize: currentMsg.fileSize,
          localFilePath: currentMsg.localFilePath,
          status: 'error',
        );
        await localRepo.saveMessage(errorMsg);
        final list = state.value ?? [];
        final idx = list.indexWhere((m) => m.id == currentMsg.id);
        if (idx != -1) {
          final updated = List<MessageModel>.from(list);
          updated[idx] = errorMsg;
          state = AsyncData(updated);
        }
      }
    });
  }

  Future<void> downloadFile(String messageId) async {
    final currentMessages = state.value ?? [];
    final idx = currentMessages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    
    final msg = currentMessages[idx];
    if (msg.fileId == null || msg.localFilePath != null) return;

    try {
      final payload = ChatMessagePayload.fromJson(jsonDecode(msg.content));
      if (payload.fileKey == null || payload.fileName == null) return;

      final fileService = ref.read(fileServiceProvider);
      final localPath = await fileService.downloadAndDecryptFile(
          msg.fileId!, payload.fileName!, payload.fileKey!);

      final updatedMsg = MessageModel(
        id: msg.id,
        chatId: msg.chatId,
        senderId: msg.senderId,
        content: msg.content,
        timestamp: msg.timestamp,
        messageType: msg.messageType,
        fileId: msg.fileId,
        fileName: msg.fileName,
        fileSize: msg.fileSize,
        localFilePath: localPath,
      );

      final localRepo = ref.read(localChatRepositoryProvider);
      await localRepo.saveMessage(updatedMsg);

      final newMessages = List<MessageModel>.from(currentMessages);
      newMessages[idx] = updatedMsg;
      state = AsyncData(newMessages);
    } catch (e) {
      // Handle download error
    }
  }

  Future<void> resendMessage(MessageModel msg) async {
    if (msg.status != 'error') return;

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
    if (peerPublicKey == null) return;

    String ciphertext;
    try {
      final encryptionService = ref.read(encryptionServiceProvider);
      ciphertext = await encryptionService.encryptMessage(
        msg.content, // for files, this is already the JSON payload
        peerPublicKey,
      );
    } catch (e) {
      return;
    }

    final newMsg = MessageModel(
      id: msg.id,
      chatId: msg.chatId,
      senderId: msg.senderId,
      content: msg.content,
      timestamp: DateTime.now(),
      messageType: msg.messageType,
      fileId: msg.fileId,
      fileName: msg.fileName,
      fileSize: msg.fileSize,
      localFilePath: msg.localFilePath,
      status: 'sending',
    );

    final localRepo = ref.read(localChatRepositoryProvider);
    await localRepo.saveMessage(newMsg);

    final currentMessages = state.value ?? [];
    final idx = currentMessages.indexWhere((m) => m.id == msg.id);
    if (idx != -1) {
      final updated = List<MessageModel>.from(currentMessages);
      updated[idx] = newMsg;
      state = AsyncData(updated);
    }

    ref.read(webSocketManagerProvider.notifier).sendMessage({
      'type': 'message',
      'payload': {
        'id': newMsg.id,
        'chat_id': newMsg.chatId,
        'sender_id': 'me',
        'ciphertext': ciphertext,
        'iv': '',
        'message_type': newMsg.messageType,
        'file_id': newMsg.fileId,
      },
    });

    Future.delayed(const Duration(seconds: 10), () async {
      final currentMsg = await localRepo.getMessage(newMsg.id);
      if (currentMsg != null && currentMsg.status == 'sending') {
        final errorMsg = MessageModel(
          id: currentMsg.id,
          chatId: currentMsg.chatId,
          senderId: currentMsg.senderId,
          content: currentMsg.content,
          timestamp: currentMsg.timestamp,
          messageType: currentMsg.messageType,
          fileId: currentMsg.fileId,
          fileName: currentMsg.fileName,
          fileSize: currentMsg.fileSize,
          localFilePath: currentMsg.localFilePath,
          status: 'error',
        );
        await localRepo.saveMessage(errorMsg);
        final list = state.value ?? [];
        final i = list.indexWhere((m) => m.id == currentMsg.id);
        if (i != -1) {
          final upd = List<MessageModel>.from(list);
          upd[i] = errorMsg;
          state = AsyncData(upd);
        }
      }
    });
  }
}
