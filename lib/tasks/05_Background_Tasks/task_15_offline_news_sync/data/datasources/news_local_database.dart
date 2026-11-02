
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/news_article.dart';
import '../../domain/models/sync_queue_item.dart';

import '../../domain/models/sync_session.dart';


class ArticleUpsertResult {
  const ArticleUpsertResult({
    required this.inserted,
    required this.updated,
  });

  final int inserted;
  final int updated;
}

class NewsLocalDatabase {
  NewsLocalDatabase._();

  static final NewsLocalDatabase instance =NewsLocalDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final root = await getDatabasesPath();

    final db = await openDatabase(
      join(
        root,
        'task15_offline_news.db',
      ),
      version: 1,
      onConfigure: (db) async {
        await db.execute(
          'PRAGMA foreign_keys = ON',
        );
      },
      onCreate: (db, version) async {
        // bảng lưu bài viết, đường dẫn ảnh cache và tr.thais đọc
        await db.execute('''
          CREATE TABLE articles(

            article_key TEXT PRIMARY KEY,
            source_name TEXT NOT NULL,
            author TEXT,

            title TEXT NOT NULL,
            description TEXT,

            url TEXT NOT NULL,
            published_at TEXT,
            thumbnail_url TEXT,
            thumbnail_local_path TEXT,

            bookmarked INTEGER NOT NULL DEFAULT 0,
            is_read INTEGER NOT NULL DEFAULT 0,

            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            last_sync_session TEXT
          )
        ''');

        await db.execute('''
          CREATE UNIQUE INDEX
          idx_articles_url
          ON articles(url)
        ''');

        // bảng giữ thao tác offl, số lần thử và thời điểm retry
        await db.execute('''
          CREATE TABLE sync_queue(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idempotency_key TEXT NOT NULL UNIQUE,
            action TEXT NOT NULL,
            article_key TEXT NOT NULL,
            payload_json TEXT NOT NULL,

            status TEXT NOT NULL DEFAULT 'pending',
            attempt_count INTEGER NOT NULL DEFAULT 0,

            next_retry_at TEXT,
            last_error TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_queue_status
          ON sync_queue(status)
        ''');

        // bảng ghi thời điểm và kquả của từng lần đồng bộ
        await db.execute('''
          CREATE TABLE sync_sessions(
            session_id TEXT PRIMARY KEY,
            trigger_type TEXT NOT NULL,
            status TEXT NOT NULL,
            started_at TEXT NOT NULL,
            completed_at TEXT,
            
            article_count INTEGER NOT NULL DEFAULT 0,
            new_count INTEGER NOT NULL DEFAULT 0,
            image_count INTEGER NOT NULL DEFAULT 0,
            duplicate_count INTEGER NOT NULL DEFAULT 0,
            queue_processed INTEGER NOT NULL DEFAULT 0,
            error_message TEXT
          )
        ''');
      },
    );

    _database = db;
    return db;
  }

  //ghi/upsert ds tin bằng transaction
  Future<ArticleUpsertResult> upsertArticles({
    required List<NewsArticle> articles,
    required String sessionId,
  }) async {
    final db = await database;

    int inserted = 0;
    int updated = 0;

    await db.transaction(
      (txn) async {
        for (final article in articles) {
          final existing = await txn.query('articles',
            columns: [
              'article_key',
              'bookmarked',
              'is_read',
              'created_at',
            ],
            where: 'article_key = ?',
            whereArgs: [
              article.articleKey,
            ],
            limit: 1,
          );

          if (existing.isEmpty) {
            await txn.insert(
              'articles',
              {
                ...article.toDb(
                  sessionId: sessionId,
                ),
                'bookmarked': 0,
                'is_read': 0,
                'created_at':
                    DateTime.now()
                        .toIso8601String(),
              },
            );

            inserted++;
          } else {
            await txn.update(
              'articles',
              article.toDb(
                sessionId: sessionId,
              ),
              where:
                  'article_key = ?',
              whereArgs: [
                article.articleKey,
              ],
            );

            updated++;
          }
        }
      },
    );

    return ArticleUpsertResult(
      inserted: inserted,
      updated: updated,
    );
  }

  Future<List<NewsArticle>>
      getArticles() async {
    final db = await database;

    final rows = await db.query(
      'articles',
      orderBy:
          'published_at DESC, updated_at DESC',
    );

    return rows
        .map(NewsArticle.fromDb)
        .toList();
  }

  // đổi tr.thái yêu thích ở SQLite và ghi thao tác cần đồng bộ vào queue
  Future<void> toggleBookmark(
    NewsArticle article,
  ) async {
    final db = await database;

    final nextValue = !article.bookmarked;

    final now = DateTime.now().toIso8601String();

    final idempotencyKey = sha256 .convert( utf8.encode( 'bookmark:${article.articleKey}',
              ),
            )
            .toString();

    await db.transaction(
      (txn) async {
        await txn.update(
          'articles',
          {
            'bookmarked':
                nextValue ? 1 : 0,
            'updated_at': now,
          },
          where: 'article_key = ?',
          whereArgs: [
            article.articleKey,
          ],
        );

        await txn.insert(
          'sync_queue',
          {
            'idempotency_key':
                idempotencyKey,
            'action':
                'bookmark_upsert',
            'article_key':
                article.articleKey,
            'payload_json':
                jsonEncode({
              'bookmarked': nextValue,
            }),
            'status': 'pending',
            'attempt_count': 0,
            'next_retry_at': null,
            'last_error': null,
            'created_at': now,
            'updated_at': now,
          },
          conflictAlgorithm:
              ConflictAlgorithm.replace,
        );
      },
    );
  }

  // lưu trạng thái đã đọc trong local database
  Future<void> markRead(
    NewsArticle article,
  ) async {
    final db = await database;

    if (article.isRead) {
      return;
    }

    final now = DateTime.now() .toIso8601String();

    final key =  sha256  .convert(
              utf8.encode(
                'read:${article.articleKey}',
              ),
            )
            .toString();

    await db.transaction(
      (txn) async {
        await txn.update(
          'articles',
          {
            'is_read': 1,
            'updated_at': now,
          },
          where: 'article_key = ?',
          whereArgs: [
            article.articleKey,
          ],
        );

        await txn.insert(
          'sync_queue',
          {
            'idempotency_key': key,
            'action': 'read_state',
            'article_key':
                article.articleKey,
            'payload_json':
                '{"isRead":true}',
            'status': 'pending',
            'attempt_count': 0,
            'created_at': now,
            'updated_at': now,
          },
          conflictAlgorithm:
              ConflictAlgorithm.replace,
        );
      },
    );
  }

  Future<List<SyncQueueItem>>
      getQueue() async {
    final db = await database;

    final rows = await db.query(
      'sync_queue',
      orderBy:
          'created_at DESC',
    );

    return rows
        .map(SyncQueueItem.fromDb)
        .toList();
  }

  Future<int> acknowledgeReadyQueue() async {
    final db = await database;

    final now = DateTime.now();

    return db.transaction(
      (txn) async {
        final rows =
            await txn.query(
          'sync_queue',
          where: '''
            status IN ('pending','retry')
            AND attempt_count < 5
          ''',
        );

        int processed = 0;

        for (final row in rows) {
          final next =
              DateTime.tryParse(
            row['next_retry_at']
                    ?.toString() ??
                '',
          );

          if (next != null &&
              next.isAfter(now)) {
            continue;
          }


          await txn.update(
            'sync_queue',
            {
              'status': 'done',
              'last_error': null,
              'next_retry_at': null,
              'updated_at':
                  now.toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [
              row['id'],
            ],
          );

          processed++;
        }

        return processed;
      },
    );
  }


  Future<void> deferPendingQueue(
    String error,
  ) async {
    final db = await database;

    final delays = [
      15,
      30,
      60,
      120,
      240,
    ];

    await db.transaction(
      (txn) async {
        final rows =
            await txn.query(
          'sync_queue',
          where:
              "status IN ('pending','retry')",
        );

        for (final row in rows) {
          final previous =
              (row['attempt_count']
                          as num?)
                      ?.toInt() ??
                  0;

          final attempt =
              previous + 1;

          if (attempt >= 5) {
            await txn.update(
              'sync_queue',
              {
                'status': 'failed',
                'attempt_count':
                    attempt,
                'last_error': error,
                'updated_at':
                    DateTime.now()
                        .toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [
                row['id'],
              ],
            );

            continue;
          }

          final delaySeconds =
              delays[
                  (attempt - 1)
                      .clamp(
                        0,
                        delays.length - 1,
                      )];

          final nextRetry =
              DateTime.now().add(
            Duration(
              seconds: delaySeconds,
            ),
          );

          await txn.update(
            'sync_queue',
            {
              'status': 'retry',
              'attempt_count':
                  attempt,
              'next_retry_at':
                  nextRetry
                      .toIso8601String(),
              'last_error': error,
              'updated_at':
                  DateTime.now()
                      .toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [
              row['id'],
            ],
          );
        }
      },
    );
  }


  Future<void> clearFailedQueue() async {
    final db = await database;

    await db.delete(
      'sync_queue',
      where: "status = 'failed'",
    );
  }


  Future<void> startSession({
    required String sessionId,
    required String triggerType,
  }) async {
    final db = await database;

    await db.insert(
      'sync_sessions',
      {
        'session_id': sessionId,
        'trigger_type':
            triggerType,
        'status': 'running',
        'started_at':
            DateTime.now()
                .toIso8601String(),
      },
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  // ghi kq cuối phiên: tcông/t.bại, số tin, trùng lặp, ảnh và queue
  Future<void> finishSession({
    required String sessionId,
    required String status,
    int articleCount = 0,
    int newCount = 0,
    int imageCount = 0,
    int duplicateCount = 0,
    int queueProcessed = 0,
    String? errorMessage,
  }) async {
    final db = await database;

    await db.update(
      'sync_sessions',
      {
        'status': status,
        'completed_at':
            DateTime.now()
                .toIso8601String(),
        'article_count':
            articleCount,
        'new_count': newCount,
        'image_count':
            imageCount,
        'duplicate_count':
            duplicateCount,
        'queue_processed':
            queueProcessed,
        'error_message':
            errorMessage,
      },
      where: 'session_id = ?',
      whereArgs: [
        sessionId,
      ],
    );
  }

  Future<List<SyncSession>>
      getSessions() async {
    final db = await database;

    final rows = await db.query(
      'sync_sessions',
      orderBy:
          'started_at DESC',
      limit: 30,
    );

    return rows
        .map(SyncSession.fromDb)
        .toList();
  }

  // dọn tin không bookmark theo chính sách giữ cache
  Future<void> cleanupArticles() async {
    final db = await database;


    await db.rawDelete('''
      DELETE FROM articles
      WHERE bookmarked = 0
      AND article_key NOT IN (

        SELECT article_key
        FROM articles
        ORDER BY
          published_at DESC,
          updated_at DESC
        LIMIT 100

      )
    ''');
  }
}