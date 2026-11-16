import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/news.dart';

class DatabaseService {
  DatabaseService._();
  static final instance = DatabaseService._();
  Database? _db;

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks(
        user_id INTEGER NOT NULL,
        news_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        url TEXT NOT NULL,
        authors TEXT NOT NULL,
        news_site TEXT NOT NULL,
        published_at TEXT NOT NULL,
        image_url TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        summary TEXT NOT NULL,
        PRIMARY KEY(user_id, news_id),
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<Database> get database async {
    if (_db != null) return _db!;

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    final dir = await getDatabasesPath();
    // Menggunakan nama file baru 'spacenews_v2.db' agar otomatis ter-generate bersih
    _db = await openDatabase(
      p.join(dir, 'spacenews_v2.db'),
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onOpen: (db) async {
        await _createTables(db);
      },
    );

    try {
      await _db!.execute('PRAGMA foreign_keys = ON');
    } catch (_) {}

    return _db!;
  }

  Future<int> register(Map<String, Object?> values) async =>
      (await database).insert('users', values);

  Future<Map<String, Object?>?> userByEmail(String email) async {
    final rows = await (await database).query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> updateUser(int id, Map<String, Object?> values) async {
    await (await database).update(
      'users',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<int>> favoriteIds(int userId) async {
    final rows = await (await database).query(
      'bookmarks',
      columns: ['news_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return rows.map((r) => r['news_id'] as int).toList();
  }

  Future<List<News>> getBookmarkedNews(int userId) async {
    final rows = await (await database).query(
      'bookmarks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return rows
        .map((r) => News(
              id: r['news_id'] as int,
              title: r['title'] as String,
              url: r['url'] as String,
              authors: r['authors'] as String,
              news_site: r['news_site'] as String,
              published_at: r['published_at'] as String,
              image_url: r['image_url'] as String,
              updated_at: r['updated_at'] as String,
              summary: r['summary'] as String,
            ))
        .toList();
  }

  Future<void> addFavorite(int userId, News news) async {
    await (await database).insert(
      'bookmarks',
      {
        'user_id': userId,
        'news_id': news.id,
        'title': news.title,
        'url': news.url,
        'authors': news.authors,
        'news_site': news.news_site,
        'published_at': news.published_at,
        'image_url': news.image_url,
        'updated_at': news.updated_at,
        'summary': news.summary,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(int userId, int newsId) async {
    await (await database).delete(
      'bookmarks',
      where: 'user_id = ? AND news_id = ?',
      whereArgs: [userId, newsId],
    );
  }
}