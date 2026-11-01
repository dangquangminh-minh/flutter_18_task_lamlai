import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/visual_article.dart';

// sqlite lưu tin và bookmark theo ủl
class NewsLocalDataSource {
  Database? _db;

  //lần đầu mới tạo và các lần sau dùng lại k.nối
  Future<Database> get database async {
    if (_db != null) return _db!;

    final path = join(
      await getDatabasesPath(),
      'visual_newsroom.db',
    );

    // dùng id để k lưu trùng bài khi tải lại chủ đề
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
       await db.execute('''
        CREATE TABLE articles(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          url TEXT,
          image_url TEXT,
          source TEXT,
          published_at TEXT,
          topic TEXT,
          is_bookmarked INTEGER NOT NULL DEFAULT 0,
          cached_at TEXT,
          image_author TEXT,
          image_author_url TEXT
        )
      ''');
      },
    );

    return _db!;
  }

  
  Future<void> cacheArticles(List<VisualArticle> articles) async {
    final db = await database;
    final batch = db.batch(); //batch để giảm số lần commit khi lưu nhiều bài báo cùng lúc

    for (final article in articles) {

      final existing = await db.query(
        'articles',

        columns: ['is_bookmarked'],
        where: 'id = ?',
        whereArgs: [article.id],
        limit: 1,
      );

      final bookmarked = existing.isNotEmpty
          ? existing.first['is_bookmarked'] as int
          : 0;

      final map = article
          .copyWith(
            isBookmarked: bookmarked == 1,
            cachedAt: DateTime.now().toIso8601String(),
          )
          .toMap();

   
      batch.insert(
        'articles',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,    //cập nhật nội dung mới khi id bài báo đã tồn tại
      );
    }

    await batch.commit(noResult: true);
  }

  //đọc bài theo chủ đề khi offline
  Future<List<VisualArticle>> getCachedArticles(String topic) async {
    final db = await database;

    final result = await db.query(
      'articles',
      where: 'topic = ?',
      whereArgs: [topic],
      orderBy: 'published_at DESC',
    );

    return result.map(VisualArticle.fromMap).toList();
  }

  
  Future<List<VisualArticle>> getBookmarks() async {
    final db = await database;

    final result = await db.query(
      'articles',
      where: 'is_bookmarked = 1', //lấy bài có is_bookmarked=1 cho tab thư viện đã lưu
      orderBy: 'published_at DESC',
    );

    return result.map(VisualArticle.fromMap).toList();
  }

  // đảo tr.thái yêu thích rồi ghi trở lại sqlite
  Future<bool> toggleBookmark(VisualArticle article) async {
    final db = await database;

    final newValue = !article.isBookmarked;

    await db.insert(
      'articles',
      article
          .copyWith(
            isBookmarked: newValue,
            cachedAt: article.cachedAt ?? DateTime.now().toIso8601String(),
          )
          .toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return newValue;
  }

  // bỏ bookmark = update
  Future<void> removeBookmark(String id) async {
    final db = await database;

    await db.update(
      'articles',
      {'is_bookmarked': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<String?> getLastCacheTime(String topic) async {
    final db = await database;

    final result = await db.query(
      'articles',
      columns: ['cached_at'],
      where: 'topic = ? AND cached_at IS NOT NULL',
      whereArgs: [topic],
      orderBy: 'cached_at DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;

    return result.first['cached_at'] as String?;
  }
}