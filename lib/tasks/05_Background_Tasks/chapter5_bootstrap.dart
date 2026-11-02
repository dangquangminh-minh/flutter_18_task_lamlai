

import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'background_task_dispatcher.dart';
import 'task_13_daily_reminder/services/reminder_notification_service.dart';


class Chapter5Bootstrap {
  Chapter5Bootstrap._();


  static Future<String?> initialize({
    required void Function(String? payload) onReminderTap,
  }) async {

    await initializeDateFormatting('vi_VN');

    // t.báo phải được khởi tạo trước khi ui xin quyền,đặt lịch
    final launchPayload =await ReminderNotificationService.instance.initialize(onNotificationTap: onReminderTap,
    );


    if (!kIsWeb &&(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      await BackgroundTaskBootstrap.initialize();
    }


    return launchPayload;
  }
}
