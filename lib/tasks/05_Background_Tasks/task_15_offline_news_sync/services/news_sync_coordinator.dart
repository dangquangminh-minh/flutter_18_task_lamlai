

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../data/datasources/news_local_database.dart';
import '../data/datasources/news_remote_data_source.dart';
import '../data/datasources/thumbnail_file_store.dart';
import '../domain/models/news_article.dart';
import '../domain/models/sync_session.dart';


class NewsSyncCoordinator {
  NewsSyncCoordinator({
    required NewsLocalDatabase local,
    required NewsRemoteDataSource remote,
    required ThumbnailFileStore thumbnails,
  }) : _local = local, _remote = remote,_thumbnails = thumbnails;

  final NewsLocalDatabase _local;
  final NewsRemoteDataSource _remote;
  final ThumbnailFileStore _thumbnails;

  // tạo session id trước khi gọi mạng
  Future<SyncSession> sync({
    required String triggerType,
    required String query,
    required String newsApiKey,
    required String pixabayApiKey,
  }) async {
    final sessionId ='SYNC-${DateTime.now().millisecondsSinceEpoch}';

    await _local.startSession(
      sessionId: sessionId,
      triggerType: triggerType,
    );

    try {
      final news =await _retry(
        () => _remote.fetchNews(
          apiKey: newsApiKey,
          query: query,
        ),
      );

      // gọi Pixabay độc lập để lấy thumbnail
      final images =  await _retry( () => _remote.fetchPixabayImages( apiKey: pixabayApiKey,
        ),
      );

      final articles =  <NewsArticle>[];

      int cachedImages = 0;

      for (int i = 0; i < news.length; i++) {
        final remoteArticle = news[i];

        final published =  remoteArticle.publishedAt;


        final articleKey = sha256.convert(
                  utf8.encode(
                    '${remoteArticle.url}|'
                    '${published?.toIso8601String() ?? ''}',
                  ),
                )
                .toString();

        String? imageUrl;
        String? localPath;

        // Ghép ảnh vòng tròn theo vị trí tin; lưu ảnh local phục vụ xem offline.
        if (images.isNotEmpty) {
          imageUrl =
              images[i %images.length].imageUrl;

          localPath =  await _thumbnails.cacheImage(imageUrl,
          );

          if (localPath != null) {
            cachedImages++;
          }
        }

        articles.add(
          NewsArticle(
            articleKey:
                articleKey,
            sourceName:
                remoteArticle
                    .sourceName,
            author:
                remoteArticle.author,
            title:
                remoteArticle.title,
            description:
                remoteArticle.description,
            url:
                remoteArticle.url,
            publishedAt:
                published,
            thumbnailUrl:
                imageUrl,
            thumbnailLocalPath:
                localPath,
            updatedAt:
                DateTime.now(),
          ),
        );
      }

      // Ghi dữ liệu vào SQLite và đếm số bản ghi thêm mới/cập nhật trùng.
      final upsert =  await _local.upsertArticles(
        articles: articles,
        sessionId: sessionId,
      );

      final queueProcessed =  await _local
              // Chỉ xác nhận queue sau khi đồng bộ thành công; khi lỗi thì hoãn retry.
              .acknowledgeReadyQueue();

      await _local.finishSession(
        sessionId: sessionId,
        status: 'success',
        articleCount:
            articles.length,
        newCount:
            upsert.inserted,
        imageCount:
            cachedImages,
        duplicateCount:
            upsert.updated,
        queueProcessed:
            queueProcessed,
      );

      final sessions =  await _local.getSessions();

      return sessions.first;

    } on NewsSyncRemoteException catch (e) {
      await _local.deferPendingQueue(
        e.message,
      );

      await _local.finishSession(
        sessionId: sessionId,
        status: 'failed',
        errorMessage:
            e.message,
      );

      rethrow;
    } catch (e) {
      await _local.deferPendingQueue(
        e.toString(),
      );

      await _local.finishSession(
        sessionId: sessionId,
        status: 'failed',
        errorMessage:
            e.toString(),
      );

      rethrow;
    }
  }

  // thử tối đa 3l
  Future<T> _retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
  }) async {
    Object? lastError;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await operation();
      } on NewsSyncRemoteException catch (e) {
        lastError = e;

        if (!e.retryable || attempt == maxAttempts - 1) {
          rethrow;
        }

        final delay =  Duration( seconds: 1 << attempt,
        );

        await Future<void>.delayed( delay, );
      }
    }

    throw lastError ??
        const NewsSyncRemoteException(
          'Không thể đồng bộ.',
          retryable: true,
        );
  }
}