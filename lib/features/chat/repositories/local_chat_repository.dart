import 'dart:io' as dart_io;
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
      where: 'deleted_at IS NULL OR last_message_time > deleted_at',
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
    await db.delete('chats', where: 'id = ?', whereArgs: [chatId]);
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
    await db.update(
      'messages',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> deleteExpiredMessages() async {
    final db = await _dbService.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final count = await db.update(
      'messages',
      {'is_deleted': 1},
      where: 'is_deleted = 0 AND expires_at IS NOT NULL AND expires_at <= ?',
      whereArgs: [now],
    );
    return count > 0;
  }

  Future<List<MessageModel>> getMessagesForChat(
    String chatId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await _dbService.database;
    final chat = await getChat(chatId);
    final deletedAt = chat?.deletedAt?.millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: deletedAt != null
          ? 'chat_id = ? AND timestamp > ? AND is_deleted = 0'
          : 'chat_id = ? AND is_deleted = 0',
      whereArgs: deletedAt != null ? [chatId, deletedAt] : [chatId],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return MessageModel.fromMap(maps[i]);
    });
  }


  Future<int> getUnreadCount(String chatId, String currentUserId) async {
    final db = await _dbService.database;
    final chat = await getChat(chatId);
    final deletedAt = chat?.deletedAt?.millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM messages 
      WHERE chat_id = ? 
      AND sender_id != ? 
      AND is_read = 0 
      AND is_deleted = 0
      ${deletedAt != null ? 'AND timestamp > ?' : ''}
      ''',
      deletedAt != null ? [chatId, currentUserId, deletedAt] : [chatId, currentUserId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
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

  Future<void> clearOldCache(int retentionDays) async {
    if (retentionDays <= 0) return;

    final db = await _dbService.database;
    final cutoff = DateTime.now()
        .subtract(Duration(days: retentionDays))
        .millisecondsSinceEpoch;

    // Find all messages older than cutoff that have a local file
    final maps = await db.query(
      'messages',
      where: 'timestamp < ? AND local_file_path IS NOT NULL',
      whereArgs: [cutoff],
    );

    for (final map in maps) {
      final path = map['local_file_path'] as String?;
      if (path != null) {
        try {
          final file = dart_io.File(path);
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (_) {}
      }
    }

    // Update db to set local_file_path to null
    await db.update(
      'messages',
      {'local_file_path': null},
      where: 'timestamp < ? AND local_file_path IS NOT NULL',
      whereArgs: [cutoff],
    );
  }
}

@riverpod
LocalChatRepository localChatRepository(Ref ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return LocalChatRepository(dbService);
}
