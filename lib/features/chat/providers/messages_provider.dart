import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../repositories/local_chat_repository.dart';
import '../../../core/network/websocket_manager.dart';
import '../../../core/network/websocket_service.dart';

part 'messages_provider.g.dart';

@riverpod
class Messages extends _$Messages {
  @override
  FutureOr<List<MessageModel>> build(String chatId) async {
    final localRepo = ref.read(localChatRepositoryProvider);
    
    // Subscribe to real-time WebSocket messages
    final wsService = ref.watch(webSocketServiceProvider);
    
    final sub = wsService.messages.listen((payload) async {
      if (payload['type'] == 'message') {
         final data = payload['payload'];
         if (data['chat_id'] == chatId) {
           final msg = MessageModel(
             id: data['id'],
             chatId: data['chat_id'],
             senderId: data['sender_id'],
             content: data['ciphertext'] ?? 'Encrypted message',
             timestamp: DateTime.parse(data['created_at']),
           );
           await localRepo.saveMessage(msg);
           
           // Update UI instantly
           final currentMessages = state.value ?? [];
           state = AsyncData([msg, ...currentMessages]);
         }
      }
    });
    
    ref.onDispose(() => sub.cancel());

    // Initial load from SQLite
    return await localRepo.getMessagesForChat(chatId);
  }

  Future<void> sendMessage(String content) async {
    final senderId = 'me'; // Fixed to 'me' for visual grouping
    final msgId = const Uuid().v4();

    // 1. Optimistic UI update and save locally
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
        'sender_id': msg.senderId,
        'ciphertext': msg.content, // Will implement encryption later
        'message_type': 'text'
      }
    });
  }
}
