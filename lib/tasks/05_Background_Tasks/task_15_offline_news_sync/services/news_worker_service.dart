
import 'package:dio/dio.dart';
import 'package:workmanager/workmanager.dart';

import '../data/datasources/news_local_database.dart';
import '../data/datasources/news_remote_data_source.dart';
import '../data/datasources/thumbnail_file_store.dart';

import '../domain/models/news_sync_settings.dart';

import 'news_sync_coordinator.dart';
import 'news_sync_notification_service.dart';

const newsPeriodicTaskName = 'task15_news_periodic';

const newsPeriodicUniqueName = 'task15_news_periodic_unique';

const newsOneOffTaskName = 'task15_news_one_off';


class NewsWorkerExecutor {
  // đọc api key và settings từ inputData, chạy Coordinator, xác định retry theo kết quả
  static Future<bool> execute({
    required String taskName,
    required Map<String, dynamic> inputData,
  }) async {
    final newsKey = inputData['newsApiKey'] ?.toString() ??'';

    final pixabayKey = inputData['pixabayApiKey']  ?.toString() ?? '';

    final query = inputData['query']  ?.toString() ?? 'mobile';

    final notify = inputData['notifications'] ==  true;

    final dio = Dio();

    final coordinator =  NewsSyncCoordinator(
      local:
          NewsLocalDatabase.instance,
      remote:
          NewsRemoteDataSource(
        dio: dio,
      ),
      thumbnails:
          ThumbnailFileStore(
        dio: dio,
      ),
    );

    try {
      final session = await coordinator.sync(
        triggerType:
            taskName == newsPeriodicTaskName
                ? 'periodic-worker'
                : 'one-off-worker',
        query: query,
        newsApiKey: newsKey,
        pixabayApiKey:
            pixabayKey,
      );

      if (notify &&  session.newCount > 0) { await NewsSyncNotificationService.showSuccess(
          newCount:session.newCount,
        );
      }

      return true;
    } on NewsSyncRemoteException catch (e) {
      return !e.retryable;
    } catch (_) {
      return false;
    }
  }
}

// điều khiển lịch WorkManager cho sync tin, một lần và xử lý queue
class NewsWorkerManager {
  NewsWorkerManager._();


  static Map<String, dynamic> _input({
    required NewsSyncSettings settings,
    required String newsApiKey,
    required String pixabayApiKey,
  }) {
    return {
      'query': settings.query,
      'newsApiKey':
          newsApiKey,
      'pixabayApiKey':
          pixabayApiKey,
      'notifications':
          settings.notificationsEnabled,
    };
  }

  // giới hạn job theo điều kiện mạng do người dùng chọn
  static Constraints _constraints(
    NewsSyncSettings settings,
  ) {
    return Constraints(
      networkType:
          settings.wifiOnly
              ? NetworkType.unmetered
              : NetworkType.connected,
      requiresBatteryNotLow: true,
      requiresStorageNotLow: true,
    );
  }

  // Đk job định kỳ bằng uniqueName để tránh trùng các chu kỳ
  static Future<void> registerPeriodic({
    required NewsSyncSettings settings,
    required String newsApiKey,
    required String pixabayApiKey,
  }) {
    final frequency =Duration(minutes:settings.intervalMinutes < 15 ? 15 : settings.intervalMinutes,
    );

    return Workmanager()
        .registerPeriodicTask(
      newsPeriodicUniqueName,
      newsPeriodicTaskName,
      frequency: frequency,
      inputData: _input(
        settings: settings,
        newsApiKey:
            newsApiKey,
        pixabayApiKey:
            pixabayApiKey,
      ),
      constraints:
          _constraints(settings),
      existingWorkPolicy:
          ExistingPeriodicWorkPolicy.update,
      backoffPolicy:
          BackoffPolicy.exponential,
      backoffPolicyDelay:
          const Duration(seconds: 30),
      tag: 'task15-news',
    );
  }

  // cho phép đồng bộ nền một lần
  static Future<void> triggerOneOff({
    required NewsSyncSettings settings,
    required String newsApiKey,
    required String pixabayApiKey,
  }) {
    return Workmanager()
        .registerOneOffTask(
      'task15_sync_'
      '${DateTime.now().millisecondsSinceEpoch}',
      newsOneOffTaskName,
      inputData: _input(
        settings: settings,
        newsApiKey:
            newsApiKey,
        pixabayApiKey:
            pixabayApiKey,
      ),
      constraints:
          _constraints(settings),
      existingWorkPolicy:
          ExistingWorkPolicy.replace,
      backoffPolicy:
          BackoffPolicy.exponential,
      backoffPolicyDelay:
          const Duration(seconds: 30),
      tag: 'task15-news',
    );
  }

  // lên lịch xử lý queue khi kết nối phục hồi với backoff nếu gặp lỗi.
  static Future<void> scheduleQueueFlush({
    required NewsSyncSettings settings,
    required String newsApiKey,
    required String pixabayApiKey,
  }) {

    return Workmanager()
        .registerOneOffTask(
      'task15_queue_flush',
      newsOneOffTaskName,
      inputData: _input(
        settings: settings,
        newsApiKey:
            newsApiKey,
        pixabayApiKey:
            pixabayApiKey,
      ),
      constraints: Constraints(
        networkType:
            NetworkType.connected,
      ),
      existingWorkPolicy:
          ExistingWorkPolicy.replace,
      backoffPolicy:
          BackoffPolicy.exponential,
      backoffPolicyDelay:
          const Duration(seconds: 30),
      tag:
          'task15-queue',
    );
  }

  // tắt lịch định kỳ nhưng kh xóa tin đã đồng bộ hoặc bookmark offline
  static Future<void> cancelPeriodic() {
    return Workmanager()
        .cancelByUniqueName(
      newsPeriodicUniqueName,
    );
  }
}