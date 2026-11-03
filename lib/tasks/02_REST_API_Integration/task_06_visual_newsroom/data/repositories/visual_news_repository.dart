import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../domain/models/visual_article.dart';
import '../datasources/news_local_data_source.dart';


import '../datasources/news_remote_data_source.dart';

import '../datasources/unsplash_remote_data_source.dart';


class VisualNewsRepository {
  VisualNewsRepository({
    required this._newsRemote,
    required this._unsplashRemote,
    required this._local,
  });

  final NewsRemoteDataSource _newsRemote;
  final UnsplashRemoteDataSource _unsplashRemote;
  final NewsLocalDataSource _local;

  //ui hiển thị dữ liệu cũ từ sqlite
  bool lastUsedCache = false;



  Future<bool> get isOnline async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  // thử tin trên mạng trước, b.sung ảnh còn thiếu rồi ghi cache để lần sau đọc off
  Future<List<VisualArticle>>  getNews({required String topic, required int page}) async {
    lastUsedCache = false;
    try {

      if (!await isOnline) throw Exception('Thiết bị đang offline.');
      final raw = await _retry(() => _newsRemote.fetchNews(topic: topic, page: page));

      //tìm một ảnh Unsplash cho mỗi đợt tải, dùng chung cho các bài thiếu ảnh
      UnsplashImageResult? fallback;
      if (raw.any((item) => item.imageUrl.isEmpty)) {
        try {
          fallback = await _unsplashRemote.searchImage(topic);
        } catch (_) {

        }
      }

      // giữ ảnh có sẵn của newsapi, chỉ thêm ảnh unsplash cho các bài thiếu
      final enriched = raw.map((article) {
        if (article.imageUrl.isNotEmpty || fallback == null) return article;
        return article.copyWith(
          imageUrl: fallback.imageUrl,
          imageAuthor: fallback.photographerName,
          imageAuthorUrl: fallback.photographerUrl,
        );
      }).toList();

      await _local.cacheArticles(enriched);


      final savedIds = (await _local.getBookmarks()).map((a) => a.id).toSet();
      return enriched.map((item) => item.copyWith(
        isBookmarked: savedIds.contains(item.id),
      )).toList();
    } catch (_) {

      if (page != 1) rethrow;

      final cached = await _local.getCachedArticles(topic);
      if (cached.isEmpty) rethrow;
      lastUsedCache = true;
      return cached;
    }
  }

  Future<List<VisualArticle>> getCachedNews(String topic) => _local.getCachedArticles(topic);
  Future<List<VisualArticle>> getBookmarks() => _local.getBookmarks();
  Future<bool> toggleBookmark(VisualArticle article) => _local.toggleBookmark(article);

  Future<void> removeBookmark(String id) => _local.removeBookmark(id);
  Future<String?> getLastCacheTime(String topic) => _local.getLastCacheTime(topic);

  // retry tối đa 3 lần cho lỗi tạm thời
  Future<T> _retry<T>(Future<T> Function() action) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await action();
      } catch (error) {
        if (error is DioException) {
          final status = error.response?.statusCode;
          final retryable = error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError ||
              status == 429 || (status != null && status >= 500);
          // 401/403/404 thường không tự hết khi gọi lại, nên trả lỗi sớm để tiết kiệm quota.
          if (!retryable) rethrow;
        }
        if (attempt == 2) rethrow;
        await Future.delayed(Duration(milliseconds: 600 * (1 << attempt)));
      }
    }
    throw StateError('Không thể tải bản tin.');
  }
}
