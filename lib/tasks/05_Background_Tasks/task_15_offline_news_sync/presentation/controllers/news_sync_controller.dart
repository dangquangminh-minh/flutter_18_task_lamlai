import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../data/datasources/news_local_database.dart';
import '../../data/datasources/news_sync_settings_store.dart';


import '../../data/repositories/news_sync_repository.dart';
import '../../domain/models/news_article.dart';
import '../../domain/models/news_sync_settings.dart';

import '../../domain/models/sync_queue_item.dart';
import '../../domain/models/sync_session.dart';

import '../../services/news_sync_notification_service.dart';
import '../../services/news_worker_service.dart';

enum NewsSyncUiState { loading, ready, syncing }


class NewsSyncController extends ChangeNotifier {
  NewsSyncController({required this.newsApiKey, required this.pixabayApiKey}) {
    repository = NewsSyncRepository(local: NewsLocalDatabase.instance);
  }

  final String newsApiKey;
  final String pixabayApiKey;

  final settingsStore = NewsSyncSettingsStore();
  final Connectivity connectivity = Connectivity();
  late final NewsSyncRepository repository;

  StreamSubscription<List<ConnectivityResult>>? _connectionSubscription;


  NewsSyncUiState state = NewsSyncUiState.loading;
  NewsSyncSettings settings = NewsSyncSettings.defaults();

  List<NewsArticle> articles = [];

  List<SyncQueueItem> queue = [];
  List<SyncSession> sessions = [];


  List<ConnectivityResult> connection = [ConnectivityResult.none];

  String search = '';
  String filter = 'all';

  String? feedback;

  // các thuộc tính tính toán để giao diện hthị số liệu hiện tại
  bool get online => connection.any((item) => item != ConnectivityResult.none);
  int get pendingCount => queue.where((item) => item.pending).length;

  int get failedCount => queue.where((item) => item.failed).length;
  int get bookmarkCount => articles.where((item) => item.bookmarked).length;


  SyncSession? get latestSession => sessions.isEmpty ? null : sessions.first;

  // tìm kiếm và lọc trên dữ liệu đã lưu
  List<NewsArticle> get visibleArticles {
    Iterable<NewsArticle> result = articles;
    final query = search.trim().toLowerCase();

    if (query.isNotEmpty) {

      result = result.where((article) {
        return article.title.toLowerCase().contains(query) || article.sourceName.toLowerCase().contains(query) || (article.author ?? '').toLowerCase().contains(query);
      });
    }

    if (filter == 'bookmarked') {
      result = result.where((article) => article.bookmarked);
    }

    if (filter == 'pending') {
      final pendingKeys = queue
          .where((item) => item.pending || item.failed)
          .map((item) => item.articleKey)
          .toSet();

      result = result.where(
        (article) => pendingKeys.contains(article.articleKey),
      );
    }

    return result.toList();
  }

  // đọc cài đặt, lấy dữ liệu sqlite và lắng nghe thay đổi kết nối mạng
  Future<void> initialize() async {
    settings = await settingsStore.load();
    connection = await connectivity.checkConnectivity();
    await refreshLocal();

    _connectionSubscription = connectivity.onConnectivityChanged.listen((
      value,
    ) async {
      final wasOffline = !online;
      connection = value;
      notifyListeners();

      //có mạng trở lại, đk xử lý các thao tác còn chờ
      if (wasOffline && online && pendingCount > 0) {
        feedback = 'Có mạng trở lại. Đã gửi hàng đợi cho WorkManager.';
        await _scheduleQueueFlush();
        notifyListeners();
      }
    });

    state = NewsSyncUiState.ready;
    notifyListeners();
  }

  // tải lại tin, hàng đợi và ls đồng bộ từ sqlite mà k cần internet
  Future<void> refreshLocal() async {
    articles = await repository.articles();
    queue = await repository.queue();
    sessions = await repository.sessions();
    notifyListeners();
  }

  // thay đổi từ khóa tìm kiếm trên danh sách tin đã lưu
  void updateSearch(String value) {
    search = value;
    notifyListeners();
  }

  // thay đổi bộ lọc tin và yc ui update
  void setFilter(String value) {
    filter = value;
    notifyListeners();
  }

  // lưu tr.thái bookmark vào sqlite trước, sau đó xếp lịch xử lý hàng đợi
  Future<void> toggleBookmark(NewsArticle article) async {
    await repository.toggleBookmark(article);
    await refreshLocal();

    // workmanager sẽ chờ đủ đ.kiện mạng nếu thiết bị đang offl
    await _scheduleQueueFlush();

    feedback = online
        ? 'Đã lưu bookmark và xếp hàng đồng bộ.'
        : 'Đã bookmark offline. Đang chờ có mạng.';

    notifyListeners();
  }


  Future<void> triggerSync() async {
    if (newsApiKey.isEmpty || pixabayApiKey.isEmpty) {
      feedback = 'Thiếu NEWS_API_KEY hoặc PIXABAY_API_KEY trong .env.';
      notifyListeners();
      return;
    }

    final before = latestSession?.startedAt;
    state = NewsSyncUiState.syncing;
    feedback = 'Đã enqueue One-off Worker...';
    notifyListeners();

    try {
      await NewsWorkerManager.triggerOneOff(
        settings: settings,
        newsApiKey: newsApiKey,
        pixabayApiKey: pixabayApiKey,
      );

      // ktra sqlite max 20l để tìm phiên đồng bộ mới
      for (int i = 0; i < 20; i++) {
        await Future<void>.delayed(const Duration(seconds: 1));
        await refreshLocal();

        final after = latestSession?.startedAt;

        if (after != null && (before == null || after.isAfter(before))) {
          feedback = latestSession!.status == 'success'
              ? 'Đồng bộ hoàn tất: ${latestSession!.newCount} tin mới.'
              : 'Worker hoàn tất nhưng gặp lỗi.';
          break;
        }
      }
    } catch (e) {
      feedback = 'Không enqueue được Worker: $e';
    }

    state = NewsSyncUiState.ready;
    notifyListeners();
  }

  // đăng ký đồng bộ định kỳ
  Future<void> registerWorker() async {
    if (newsApiKey.isEmpty || pixabayApiKey.isEmpty) {
      feedback = 'Thiếu API key.';
      notifyListeners();
      return;
    }

    await NewsWorkerManager.registerPeriodic(
      settings: settings,
      newsApiKey: newsApiKey,
      pixabayApiKey: pixabayApiKey,
    );

    settings = settings.copyWith(workerEnabled: true);
    await settingsStore.save(settings);

    feedback = 'Periodic Worker đã được bật.';
    notifyListeners();
  }

  // hủy lịch đồng bộ định kỳ
  Future<void> cancelWorker() async {
    await NewsWorkerManager.cancelPeriodic();

    settings = settings.copyWith(workerEnabled: false);
    await settingsStore.save(settings);

    feedback = 'Đã tắt Periodic Worker.';
    notifyListeners();
  }

  // đổi c.kỳ đồng bộ và đăng ký lại worker nếu đang bật
  Future<void> setInterval(int value) async {
    settings = settings.copyWith(intervalMinutes: value);
    await settingsStore.save(settings);

    if (settings.workerEnabled) {
      await registerWorker();
    }

    notifyListeners();
  }


  Future<void> setWifiOnly(bool value) async {
    settings = settings.copyWith(wifiOnly: value);
    await settingsStore.save(settings);

    if (settings.workerEnabled) {
      await registerWorker();
    }

    notifyListeners();
  }

  // xin quyền trước khi bật tbáo và lưu cấu hình đã chọn
  Future<void> setNotifications(bool value) async {
    if (value) {
      final permission = await NewsSyncNotificationService.requestPermission();

      if (!permission) {
        feedback = 'Chưa được cấp quyền notification.';
        notifyListeners();
        return;
      }
    }

    settings = settings.copyWith(notificationsEnabled: value);
    await settingsStore.save(settings);

    notifyListeners();
  }

  // gửi y/cầu thử x.lý lại các thao tác còn trong hàng đợi
  Future<void> retryQueue() async {
    await _scheduleQueueFlush();

    feedback = online
        ? 'Đã gửi queue cho WorkManager.'
        : 'Vẫn offline. Worker sẽ chờ có mạng.';

    notifyListeners();
  }


  Future<void> clearFailed() async {
    await repository.clearFailedQueue();
    await refreshLocal();

    feedback = 'Đã xóa các task hết lượt retry.';
    notifyListeners();
  }


  Future<void> cleanupCache() async {
    await repository.cleanup();
    await refreshLocal();

    feedback = 'Đã dọn cache, vẫn giữ bookmark.';
    notifyListeners();
  }

  // tạo tác vụ chạy 1l để xlý hàng đợi khi đủ điều kiện mạng
  Future<void> _scheduleQueueFlush() {
    return NewsWorkerManager.scheduleQueueFlush(
      settings: settings,
      newsApiKey: newsApiKey,
      pixabayApiKey: pixabayApiKey,
    );
  }


  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}
