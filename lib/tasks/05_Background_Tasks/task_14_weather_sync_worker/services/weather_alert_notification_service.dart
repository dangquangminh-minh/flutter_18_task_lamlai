

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../domain/models/weather_snapshot.dart';


class WeatherAlertNotificationService {
  WeatherAlertNotificationService._();

  static const payload = 'task14_weather_alert';

  static const channelId = 'task14_heat_alerts';


  static Future<bool>
      requestAndroidPermission() async {
    final plugin =  FlutterLocalNotificationsPlugin();

    final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) {
      return true;
    }

    final enabled = await android.areNotificationsEnabled() ?? false;

    if (enabled) {
      return true;
    }

    return await android.requestNotificationsPermission() ?? false;
  }

  // bắn cảnh báo khi snapshot vượt ngưỡng
  static Future<void> showHeatAlert({
    required WeatherSnapshot snapshot,
    required double threshold,
  }) async {
    final plugin =
        FlutterLocalNotificationsPlugin();

    const initialization =
        InitializationSettings(
      android:
          AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
    );

    await plugin.initialize(
      settings: initialization,
    );

    const details =  NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        'Weather Heat Alerts',
        channelDescription:
            'Cảnh báo khi nhiệt độ vượt '
            'ngưỡng người dùng đã đặt.',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await plugin.show(
      id: 1401,
      title:
          '🔥 Cảnh báo nhiệt độ',
      body:
          '${snapshot.cityName}: '
          '${snapshot.temperature.toStringAsFixed(1)}°C '
          'đã vượt ngưỡng '
          '${threshold.toStringAsFixed(0)}°C.',
      notificationDetails: details,
      payload: payload,
    );
  }
}