import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Central Sqflite database helper.
///
/// Tables:
/// - tasks           : cached copy of the last loaded task list (offline read)
/// - pending_actions  : queue of offline mutations (create/update) to sync
/// - user_session      : persisted logged-in user info
class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'team_workspace.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            remote_id INTEGER,
            task_id TEXT,
            title TEXT,
            description TEXT,
            priority TEXT,
            status TEXT,
            assigned_user TEXT,
            due_date TEXT,
            created_at TEXT,
            is_synced INTEGER DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE pending_actions (
            id TEXT PRIMARY KEY,
            action_type TEXT NOT NULL,
            payload TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE user_session (
            uid TEXT PRIMARY KEY,
            email TEXT,
            name TEXT,
            logged_in_at TEXT
          )
        ''');
      },
    );
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('tasks');
    await db.delete('pending_actions');
    await db.delete('user_session');
  }
}
