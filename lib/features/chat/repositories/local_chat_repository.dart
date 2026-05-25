import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/storage/database_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

part 'local_chat_repository.g.dart';

class LocalChatRepository {
  final DatabaseService _dbService;

  const LocalChatRepository(this._dbService);

  // === CHAT OPERATIONS ===

  Future<void> saveChat(ChatModel chat) async {
    final db = await _dbService.database;
    await db.insert(
      'chats',
      chat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatModel>> getChats() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chats',
      orderBy: 'last_message_time DESC',
    );

    return List.generate(maps.length, (i) {
      return ChatModel.fromMap(maps[i]);
    });
  }

  Future<ChatModel?> getChat(String id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chats',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ChatModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateChat(ChatModel chat) async {
    final db = await _dbService.database;
    await db.update(
      'chats',
      chat.toMap(),
      where: 'id = ?',
      whereArgs: [chat.id],
    );
  }

  Future<void> deleteChat(String chatId) async {
    final db = await _dbService.database;
    await db.delete(
      'chats',
      where: 'id = ?',
      whereArgs: [chatId],
    );
    // Messages will be deleted automatically due to ON DELETE CASCADE
  }

  // === MESSAGE OPERATIONS ===

  Future<void> saveMessage(MessageModel message) async {
    final db = await _dbService.database;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MessageModel?> getMessage(String id) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MessageModel.fromMap(maps.first);
  }

  Future<void> deleteMessage(String id) async {
    final db = await _dbService.database;
    await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MessageModel>> getMessagesForChat(String chatId, {int limit = 50, int offset = 0}) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return MessageModel.fromMap(maps[i]);
    });
  }

  Future<void> markMessagesAsRead(String chatId) async {
    final db = await _dbService.database;
    await db.update(
      'messages',
      {'is_read': 1},
      where: 'chat_id = ? AND is_read = 0',
      whereArgs: [chatId],
    );
  }
}

@riverpod
LocalChatRepository localChatRepository(Ref ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return LocalChatRepository(dbService);
}
