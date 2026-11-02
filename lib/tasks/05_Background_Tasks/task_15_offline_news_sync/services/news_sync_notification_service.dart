

import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NewsSyncNotificationService {
  NewsSyncNotificationService._();

  static const payload = 'task15_news_sync';

  static Future<bool>
      // kiểm tra quyền notification
      requestPermission() async {
    final plugin = FlutterLocalNotificationsPlugin();

    final android = plugin.resolvePlatformSpecificImplementation< AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) {
      return true;
    }

    final enabled = await android.areNotificationsEnabled() ?? false;

    if (enabled) {
      return true;
    }

    return await android.requestNotificationsPermission() ??
        false;
  }

  // hiện kq phiên đồng bộ để người dùng biết có bao nhiêu tin mới
  static Future<void> showSuccess({
    required int newCount,
  }) async {
    if (newCount <= 0) {
      return;
    }

    final plugin = FlutterLocalNotificationsPlugin();

    const initialization = InitializationSettings(
      android:AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
    );

    await plugin.initialize(
      settings: initialization,
    );

    const details = NotificationDetails(
      android:
          AndroidNotificationDetails(
        'task15_news_sync',
        'News Sync',
        channelDescription:
            'Thông báo khi Background Worker '
            'tải được tin tức mới.',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await plugin.show(
      id: 1501,
      title:
          'Đồng bộ tin tức hoàn tất',
      body:
          '$newCount tin mới đã được lưu '
          'để đọc ngoại tuyến.',
      notificationDetails:
          details,
      payload: payload,
    );
  }
}