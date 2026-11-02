
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/reminder_settings.dart';


class ReminderLocalDataSource {
  // các key khôi phục giừo,phút, ngày lặp tr.thái sau khi đóng app
  static const _hourKey ='task13_reminder_hour';

  static const _minuteKey = 'task13_reminder_minute';

  static const _daysKey = 'task13_reminder_days';

  static const _enabledKey = 'task13_reminder_enabled';


  static const _soundKey = 'task13_reminder_sound';

  static const _vibrationKey ='task13_reminder_vibration';

  // đọc từng cấu hình từ bộ nhớ local
  Future<ReminderSettings> loadSettings() async {
    final prefs =await SharedPreferences.getInstance();

    final defaults = ReminderSettings.defaults();

    final rawDays = prefs.getStringList(_daysKey);

    final days = rawDays
            ?.map(int.tryParse)
            .whereType<int>()
            .where(
              (day) => day >= 1 && day <= 7,
            )
            .toSet() ??
        defaults.repeatDays;

    return ReminderSettings(
      hour:
          prefs.getInt(_hourKey) ??
          defaults.hour,
      minute:
          prefs.getInt(_minuteKey) ??
          defaults.minute,
      repeatDays:
          days.isEmpty
              ? defaults.repeatDays
              : days,
      enabled:
          prefs.getBool(_enabledKey) ??
          false,
      sound:
          prefs.getBool(_soundKey) ??
          true,
      vibration:
          prefs.getBool(_vibrationKey) ??
          true,
    );
  }

  // ghi lại toàn bộ c.hình sau thao tác của ng.dùng để lần mở app vẫn giữ lịch
  Future<void> saveSettings(
    ReminderSettings settings,
  ) async {
    final prefs = await SharedPreferences.getInstance();


    final days =settings.repeatDays.toList()..sort();

    await Future.wait([
      prefs.setInt(
        _hourKey,
        settings.hour,
      ),
      prefs.setInt(
        _minuteKey,
        settings.minute,
      ),
      prefs.setStringList(
        _daysKey,
        days
            .map((day) => day.toString())
            .toList(),
      ),
      prefs.setBool(
        _enabledKey,
        settings.enabled,
      ),
      prefs.setBool(
        _soundKey,
        settings.sound,
      ),
      prefs.setBool(
        _vibrationKey,
        settings.vibration,
      ),
    ]);
  }
}