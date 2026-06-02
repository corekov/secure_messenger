import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_service.g.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('messenger.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE chats ADD COLUMN peer_public_key TEXT');
    }
    if (oldVersion < 3) {
      // Purge all corrupted cache data resulting from the JWT parsing bug
      await db.execute('DELETE FROM chats');
      await db.execute('DELETE FROM messages');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE chats ADD COLUMN is_online INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE chats ADD COLUMN last_seen INTEGER');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE chats ADD COLUMN peer_id TEXT');
    }
    if (oldVersion < 6) {
      await db.execute("ALTER TABLE messages ADD COLUMN message_type TEXT NOT NULL DEFAULT 'text'");
      await db.execute('ALTER TABLE messages ADD COLUMN file_id TEXT');
      await db.execute('ALTER TABLE messages ADD COLUMN file_name TEXT');
      await db.execute('ALTER TABLE messages ADD COLUMN file_size INTEGER');
      await db.execute('ALTER TABLE messages ADD COLUMN local_file_path TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const textNullable = 'TEXT';

    await db.execute('''
      CREATE TABLE chats (
        id $idType,
        name $textType,
        last_message $textType,
        last_message_time $intType,
        unread_count $intType,
        peer_public_key $textNullable,
        is_online $intType DEFAULT 0,
        last_seen INTEGER,
        peer_id $textNullable
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id $idType,
        chat_id $textType,
        sender_id $textType,
        content $textType,
        timestamp $intType,
        is_read $boolType,
        message_type $textType DEFAULT 'text',
        file_id $textNullable,
        file_name $textNullable,
        file_size INTEGER,
        local_file_path $textNullable,
        FOREIGN KEY (chat_id) REFERENCES chats (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

@Riverpod(keepAlive: true)
DatabaseService databaseService(Ref ref) {
  return DatabaseService();
}
