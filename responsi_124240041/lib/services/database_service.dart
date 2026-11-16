
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._() {
    // Inisialisasi database factory khusus Web di dalam constructor / awal class
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
  }

  static final instance = DatabaseService._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'news.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL
          )
        ''');
      
        await db.execute('''
          CREATE TABLE favorites(
            user_id INTEGER NOT NULL,
            news_id INTEGER NOT NULL,
            PRIMARY KEY(user_id, news_id),
            FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  
    try {
      await _db!.execute('PRAGMA foreign_keys = ON');
    } catch (_) {}

    return _db!;
  }

  Future<int> register(Map<String, Object?> values) async =>
      (await database).insert('users', values);

  Future<Map<String, Object?>> userByEmail(String email) async {
    final rows = await (await database).query(
      'users', 
      where: 'email = ?', 
      whereArgs: [email.toLowerCase()], 
      limit: 1,
    );
    return rows.isEmpty ? {} : rows.first;
  }

  Future<void> updateUser(int id, Map<String, Object?> values) async {
    await (await database).update('users', values, where: 'id = ?', whereArgs: [id]);
  }

  // Menggunakan 'news_id' sesuai tabel onCreate
  Future<List<int>> favoriteIds(int userId) async {
    final rows = await (await database).query(
      'favorites', 
      columns: ['news_id'], 
      where: 'user_id = ?', 
      whereArgs: [userId],
    );
    return rows.map((r) => r['news_id'] as int).toList();
  }

  Future<void> addFavorite(int userId, int newsId) async {
    await (await database).insert(
      'favorites', 
      {'user_id': userId, 'news_id': newsId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavorite(int userId, int newsId) async {
    await (await database).delete(
      'favorites', 
      where: 'user_id = ? AND news_id = ?',
      whereArgs: [userId, newsId],
    );
  }
}