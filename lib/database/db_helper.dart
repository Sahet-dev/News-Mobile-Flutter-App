import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'news_article.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'news.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE news (
            id INTEGER PRIMARY KEY,
            title TEXT,
            image_url TEXT,
            timestamp TEXT,
            category TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertArticles(List<NewsArticle> articles) async {
    final db = await database;
    for (var article in articles) {
      await db.insert('news', article.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<NewsArticle>> fetchArticles(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('news', where: 'category = ?', whereArgs: [category], limit: 20);

    return List.generate(maps.length, (i) {
      return NewsArticle(
        id: maps[i]['id'],
        title: maps[i]['title'],
        imageUrl: maps[i]['image_url'],
        timestamp: maps[i]['timestamp'],
        category: maps[i]['category'],
      );
    });
  }
}
