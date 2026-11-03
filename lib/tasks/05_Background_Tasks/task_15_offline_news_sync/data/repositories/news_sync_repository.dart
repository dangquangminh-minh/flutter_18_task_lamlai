

import '../../domain/models/news_article.dart';
import '../../domain/models/sync_queue_item.dart';
import '../../domain/models/sync_session.dart';
import '../datasources/news_local_database.dart';


class NewsSyncRepository {
  NewsSyncRepository({required this._local});

  final NewsLocalDatabase _local;

  Future<List<NewsArticle>>
      articles() {
    return _local.getArticles();
  }

  Future<List<SyncQueueItem>>
      queue() {
    return _local.getQueue();
  }

  Future<List<SyncSession>>
      sessions() {
    return _local.getSessions();
  }

  // update bookmark trg SQLite và tạo queue item cho offl
  Future<void> toggleBookmark(
    NewsArticle article,
  ) {
    return _local.toggleBookmark(
      article,
    );
  }

  // lưu cờ đã đọc khi người dùng mở tin
  Future<void> markRead(
    NewsArticle article,
  ) {
    return _local.markRead(
      article,
    );
  }

  // xóa các tác vụ queue lỗi
  Future<void> clearFailedQueue() {
    return _local.clearFailedQueue();
  }

  // gọi cơ chế dọn dẹp cache giữ lại bookmark
  Future<void> cleanup() {
    return _local.cleanupArticles();
  }
}