

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/models/reminder_settings.dart';


class ReminderPermissionState {
  const ReminderPermissionState({
    required this.notificationsGranted,
    required this.exactAlarmGranted,
  });

  final bool notificationsGranted;
  final bool exactAlarmGranted;
}


class ReminderNotificationService {
  ReminderNotificationService._();


  static final ReminderNotificationService instance =
      ReminderNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // mỗi ngày trong tuần có một notification id riêng
  static const int _baseId = 1300;
  static const int _testId = 1399;

  static const String payload =
      'task13_daily_reminder';


  static const NotificationDetails _details =
      NotificationDetails(
    android: AndroidNotificationDetails(
      'task13_daily_reminder',
      'Daily Reminder',
      channelDescription:
          'Nhắc người dùng mở ứng dụng học Flutter',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  // Kh.tạo timezone theo th.bị rồi đăng ký callback khi chạm notification
  Future<String?> initialize({
    required void Function(String? payload)
        onNotificationTap,
  }) async {
    tz_data.initializeTimeZones();

    try {
      final nativeTimezone =
          await FlutterTimezone
              .getLocalTimezone();

      final location =
          tz.getLocation(
        nativeTimezone.identifier,
      );

      tz.setLocalLocation(location);
    } catch (_) {

    }

    const android =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings =
        InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse:
          (response) {
        onNotificationTap(
          response.payload,
        );
      },
    );


    final launchDetails =
        await _plugin
            // Đọc payload khi app được mở từ trạng thái đã tắt hoàn toàn.
            .getNotificationAppLaunchDetails();

    if (launchDetails
            ?.didNotificationLaunchApp ==
        true) {
      return launchDetails
          ?.notificationResponse
          ?.payload;
    }

    return null;
  }

  Future<ReminderPermissionState>
      // kiểm tra quyền hiện tại, kh bật hộp thoại xin quyền
      getPermissionState() async {
    final android =
        _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final notifications =
          await android
                  .areNotificationsEnabled() ??
              false;

      final exact =
          await android
                  .canScheduleExactNotifications() ??
              false;

      return ReminderPermissionState(
        notificationsGranted:
            notifications,
        exactAlarmGranted: exact,
      );
    }

    // Với iOS/macOS, permission sẽ được
    // request khi người dùng bấm bật lịch.
    return const ReminderPermissionState(
      notificationsGranted: true,
      exactAlarmGranted: true,
    );
  }

  Future<ReminderPermissionState>
      // chủ động xin quyền notification
      requestPermissions() async {
    final android =
        _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      bool notifications =
          await android
                  .areNotificationsEnabled() ??
              false;

      if (!notifications) {
        notifications =
            await android
                    .requestNotificationsPermission() ??
                false;
      }

      bool exact =
          await android
                  .canScheduleExactNotifications() ??
              false;

      if (!exact) {
        await android
            .requestExactAlarmsPermission();

        exact =
            await android
                    .canScheduleExactNotifications() ??
                false;
      }

      return ReminderPermissionState(
        notificationsGranted:
            notifications,
        exactAlarmGranted: exact,
      );
    }

    final ios =
        _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

    if (ios != null) {
      final granted =
          await ios.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
              false;

      return ReminderPermissionState(
        notificationsGranted:
            granted,
        exactAlarmGranted: true,
      );
    }

    return const ReminderPermissionState(
      notificationsGranted: true,
      exactAlarmGranted: true,
    );
  }

  // hủy lịch cũ trc,sau đó tạo lịch lặp cho từng ngày được chọn
  Future<void> scheduleWeekly(
    ReminderSettings settings, {
    required String suggestion,
  }) async {
    await cancelScheduled();

    final permission =
        await getPermissionState();


    final scheduleMode =
        permission.exactAlarmGranted
            ? AndroidScheduleMode
                .exactAllowWhileIdle
            : AndroidScheduleMode
                .inexactAllowWhileIdle;

    final days =
        settings.repeatDays.toList()
          ..sort();

    for (final weekday in days) {
      final scheduledDate =
          _nextInstance(
        weekday: weekday,
        hour: settings.hour,
        minute: settings.minute,
      );

      await _plugin.zonedSchedule(
        id: _baseId + weekday,
        title:
            'Đã đến giờ học Flutter hôm nay rồi! 🚀',
        body:
            'Gợi ý: $suggestion',
        scheduledDate:
            scheduledDate,
        notificationDetails:
            _details,
        androidScheduleMode:
            scheduleMode,
        payload: payload,
        matchDateTimeComponents:
            DateTimeComponents
                .dayOfWeekAndTime,
      );
    }
  }

 
  Future<void> showNow({
    required String suggestion,
  }) async {
    await _plugin.show(
      id: _testId,
      title:
          'Daily Reminder • Test',
      body:
          'Gợi ý bài học: $suggestion',
      notificationDetails:
          _details,
      payload: payload,
    );
  }


  Future<void> scheduleTestAfter10Seconds({
    required String suggestion,
  }) async {
    await _plugin.cancel(
      id: _testId,
    );

    final permission =
        await getPermissionState();

    final mode =
        permission.exactAlarmGranted
            ? AndroidScheduleMode
                .exactAllowWhileIdle
            : AndroidScheduleMode
                .inexactAllowWhileIdle;

    await _plugin.zonedSchedule(
      id: _testId,
      title:
          'Daily Reminder • Test',
      body:
          'Test lịch nền thành công. '
          'Gợi ý: $suggestion',
      scheduledDate:
          tz.TZDateTime.now(
        tz.local,
      ).add(
        const Duration(seconds: 10),
      ),
      notificationDetails:
          _details,
      androidScheduleMode: mode,
      payload: payload,
    );
  }


  Future<void> cancelScheduled() async {
    for (int day = 1; day <= 7; day++) {
      await _plugin.cancel(
        id: _baseId + day,
      );
    }

    await _plugin.cancel(
      id: _testId,
    );
  }


  tz.TZDateTime _nextInstance({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now =
        tz.TZDateTime.now(tz.local);

    var candidate =
        tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (candidate.weekday != weekday ||
        !candidate.isAfter(now)) {
      final tomorrow =
          candidate.add(
        const Duration(days: 1),
      );

      candidate =
          tz.TZDateTime(
        tz.local,
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        hour,
        minute,
      );
    }

    return candidate;
  }
}