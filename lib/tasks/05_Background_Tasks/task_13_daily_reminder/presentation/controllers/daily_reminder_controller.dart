

import 'package:flutter/material.dart';

import '../../data/repositories/reminder_repository.dart';
import '../../domain/models/reminder_settings.dart';
import '../../domain/models/todo_suggestion.dart';
import '../../services/reminder_notification_service.dart';


enum DailyReminderStatus {
  loading,
  ready,

  error,
}


class DailyReminderController
    extends ChangeNotifier {
  DailyReminderController({
    required ReminderRepository repository,
    required ReminderNotificationService notifications,
  }) : _repository = repository,_notifications = notifications;

  final ReminderRepository _repository;
  final ReminderNotificationService _notifications;

  DailyReminderStatus status =  DailyReminderStatus.loading;

  ReminderSettings settings =ReminderSettings.defaults();

  ReminderPermissionState permission =
      const ReminderPermissionState(
    notificationsGranted: false,
    exactAlarmGranted: false,
  );

  TodoSuggestion? suggestion;

  bool suggestionLoading = false;
  String? suggestionError;

  String? errorMessage;


  Future<void> initialize() async {
    status =DailyReminderStatus.loading;

    notifyListeners();

    try {
      settings =await _repository.loadSettings();

      permission =await _notifications.getPermissionState();

      status = DailyReminderStatus.ready;

      notifyListeners();

      await refreshSuggestion();
    } catch (e) {
      errorMessage ='Không thể khôi phục cấu hình nhắc nhở.';

      status =DailyReminderStatus.error;

      notifyListeners();
    }
  }

  // tải lại gợi ý riêng biệt
  Future<void> refreshSuggestion() async {
    suggestionLoading = true;
    suggestionError = null;

    notifyListeners();

    try {
      suggestion = await _repository.getSuggestion();
    } catch (e) {
      suggestionError = e.toString();
    } finally {
      suggestionLoading = false;
      notifyListeners();
    }
  }

  // update giờ đã chọn và lưu lại lịch if reminder đang bật
  Future<void> setTime(
    TimeOfDay time,
  ) async {
    settings = settings.copyWith(
      hour: time.hour,
      minute: time.minute,
    );

    await _persistAndReschedule();

    notifyListeners();
  }

  //dateTime tự xử lý t.hợp qua 23:59 hoặc 00:00
  Future<void> adjustMinutes(
    int delta,
  ) async {
    final base = DateTime(
      2026,
      1,
      1,
      settings.hour,
      settings.minute,
    );

    final changed = base.add(
      Duration(minutes: delta),
    );

    await setTime(
      TimeOfDay(
        hour: changed.hour,
        minute: changed.minute,
      ),
    );
  }

  // bật/tắt 1 ngày trog tuần,kh cho bỏ ngày cuối để tránh lịch lặp rỗng
  Future<bool> toggleDay(
    int weekday,
  ) async {
    final days =  Set<int>.from(
      settings.repeatDays,
    );

    if (days.contains(weekday)) {
      if (days.length == 1) {
        return false;
      }

      days.remove(weekday);
    } else {
      days.add(weekday);
    }

    settings = settings.copyWith(
      repeatDays: days,
    );

    await _persistAndReschedule();

    notifyListeners();

    return true;
  }

  // chọn nhanh Thứ 2 đến Thứ 6 để áp lại lịch t.báo
  Future<void> selectWeekdays() async {
    settings =  settings.copyWith(
      repeatDays: {
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
      },
    );

    await _persistAndReschedule();
    notifyListeners();
  }

  // chọn hết luôn 7 ngày
  Future<void> selectEveryDay() async {
    settings =  settings.copyWith(
      repeatDays: {
        1,
        2,
        3,
        4,
        5,
        6,
        7,
      },
    );

    await _persistAndReschedule();
    notifyListeners();
  }

  Future<ReminderPermissionState>
      // xin quyền khi người dùng yêu cầu
      requestPermissions() async {
    permission =  await _notifications.requestPermissions();

    notifyListeners();

    return permission;
  }

  //bật lịch khi có ngày lặp và được cấp quyền; lưu t.thái sau khi đặt lịch t.công
  Future<bool> enableReminder() async {
    if (settings.repeatDays.isEmpty) {
      return false;
    }

    permission =  await _notifications.requestPermissions();

    notifyListeners();

    if (!permission.notificationsGranted) {
      return false;
    }

    settings = settings.copyWith(
      enabled: true,
    );

    await _notifications.scheduleWeekly(
      settings,
      suggestion:
          _notificationSuggestion,
    );

    await _repository.saveSettings(settings);

    notifyListeners();

    return true;
  }

  //hủy t.báo định kỳ rồi lưu tr.thái tắt để lần mở lại kh tự bật
  Future<void> disableReminder() async {
    await _notifications
        .cancelScheduled();

    settings = settings.copyWith(
      enabled: false,
    );

    await _repository.saveSettings(settings);

    notifyListeners();
  }


  Future<bool> toggleEnabled(
    bool value,
  ) async {
    if (value) {
      return enableReminder();
    }

    await disableReminder();
    return true;
  }


  Future<bool> testNow() async {
    permission =
        await _notifications
            .requestPermissions();

    notifyListeners();

    if (!permission.notificationsGranted) {
      return false;
    }

    await _notifications.showNow(
      suggestion: _notificationSuggestion,
    );

    return true;
  }


  Future<bool> testAfter10Seconds() async {
    permission =
        await _notifications.requestPermissions();

    notifyListeners();

    if (!permission.notificationsGranted) {
      return false;
    }

    await _notifications.scheduleTestAfter10Seconds(
      suggestion:
          _notificationSuggestion,
    );

    return true;
  }

  String get _notificationSuggestion {
    final title = suggestion?.title.trim();

    if (title != null && title.isNotEmpty) {
      return title;
    }

    return 'Mở ứng dụng và tiếp tục '
        'bài học Flutter hôm nay.';
  }


  Future<void> _persistAndReschedule() async {
    await _repository.saveSettings(settings);

    if (settings.enabled) {
      await _notifications.scheduleWeekly(settings,
        suggestion:
            _notificationSuggestion,
      );
    }
  }

  DateTime? get nextReminder {
    if (!settings.enabled ||
        settings.repeatDays.isEmpty) {
      return null;
    }

    final now = DateTime.now();

    DateTime? best;

    for (int offset = 0;offset <= 7; offset++) {
      final date =
          now.add(
        Duration(days: offset),
      );

      if (!settings.repeatDays.contains(date.weekday)) {
        continue;
      }

      final candidate = DateTime(
        date.year,
        date.month,
        date.day,
        settings.hour,
        settings.minute,
      );

      if (!candidate.isAfter(now)) {
        continue;
      }

      if (best == null || candidate.isBefore(best)) {
        best = candidate;
      }
    }

    return best;
  }
}