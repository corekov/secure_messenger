import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as developer;

import '../models/chat_model.dart';
import '../repositories/local_chat_repository.dart';
import '../services/chat_service.dart';

part 'chat_list_provider.g.dart';

@riverpod
class ChatList extends _$ChatList {
  @override
  FutureOr<List<ChatModel>> build() async {
    // 1. Instantly read local cached chats for optimistic UI
    final localRepo = ref.read(localChatRepositoryProvider);
    final localChats = await localRepo.getChats();
    
    // 2. Trigger background network sync
    _syncChats();
    
    return localChats;
  }

  Future<void> _syncChats() async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final localRepo = ref.read(localChatRepositoryProvider);
      
      final remoteChats = await chatService.getChats();
      
      // Parse remote chats and sync to SQLite
      for (final chatData in remoteChats) {
        String name = chatData['name'] ?? 'Unknown Chat';
        
        // For direct chats, try to extract the member's username
        if (chatData['type'] == 'direct' && chatData['members'] != null) {
           final members = chatData['members'] as List;
           if (members.isNotEmpty) {
             name = members.first['username'] ?? 'User';
           }
        }
        
        final lastMsg = chatData['last_message'];
        final String lastMessageText = lastMsg != null ? 'Encrypted Message' : 'No messages yet';
        final DateTime lastMessageTime = lastMsg != null && lastMsg['created_at'] != null 
            ? DateTime.parse(lastMsg['created_at']) 
            : DateTime.parse(chatData['created_at']);
        
        final chat = ChatModel(
          id: chatData['id'],
          name: name,
          lastMessage: lastMessageText,
          lastMessageTime: lastMessageTime,
          unreadCount: chatData['unread_count'] ?? 0,
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
}
