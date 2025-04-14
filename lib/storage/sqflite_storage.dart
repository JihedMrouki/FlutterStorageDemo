import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteStorage {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'text_storage.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE texts (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    );
  }

  Future<String?> getText(String key) async {
    final db = await database;
    final result = await db.query('texts', where: 'key = ?', whereArgs: [key]);
    return result.isNotEmpty ? result.first['value'] as String? : null;
  }

  Future<void> saveText(String key, String text) async {
    final db = await database;
    await db.insert('texts', {
      'key': key,
      'value': text,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteText(String key) async {
    final db = await database;
    await db.delete('texts', where: 'key = ?', whereArgs: [key]);
  }
}
