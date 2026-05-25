import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';

part 'chat_service.g.dart';

class ChatService {
  final Dio _dio;

  const ChatService(this._dio);

  Future<List<Map<String, dynamic>>> getChats() async {
    final response = await _dio.get('/chats');
    final data = response.data as List;
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createDirectChat(String targetUserId) async {
    final response = await _dio.post('/chats', data: {
      'type': 'direct',
      'member_ids': [targetUserId]
    });
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    final response = await _dio.get('/chats/$chatId/messages');
    final data = response.data as List;
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> deleteChat(String chatId) async {
    await _dio.delete('/chats/$chatId');
  }

  Future<void> markRead(String chatId) async {
    await _dio.post('/chats/$chatId/read');
  }
}

@riverpod
ChatService chatService(Ref ref) {
  return ChatService(ref.watch(dioClientProvider));
}
