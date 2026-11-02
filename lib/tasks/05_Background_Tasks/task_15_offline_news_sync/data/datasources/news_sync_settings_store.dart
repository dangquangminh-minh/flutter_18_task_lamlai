
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/news_sync_settings.dart';


class NewsSyncSettingsStore {

  Future<NewsSyncSettings> load() async {
    final prefs =  await SharedPreferences.getInstance();

    final defaults = NewsSyncSettings.defaults();

    return NewsSyncSettings(
      query:
          prefs.getString(
                'task15_query',
              ) ??
              defaults.query,
      intervalMinutes:
          prefs.getInt(
                'task15_interval',
              ) ??
              defaults.intervalMinutes,
      wifiOnly:
          prefs.getBool(
                'task15_wifi_only',
              ) ??
              defaults.wifiOnly,
      notificationsEnabled:
          prefs.getBool(
                'task15_notifications',
              ) ??
              defaults.notificationsEnabled,
      workerEnabled:
          prefs.getBool(
                'task15_worker_enabled',
              ) ??
              defaults.workerEnabled,
    );
  }

  // ghi lại tùy chọn sau khi người dùng thay đổi trên tab setting
  Future<void> save(
    NewsSyncSettings settings,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'task15_query',
      settings.query,
    );

    await prefs.setInt(
      'task15_interval',
      settings.intervalMinutes,
    );

    await prefs.setBool(
      'task15_wifi_only',
      settings.wifiOnly,
    );

    await prefs.setBool(
      'task15_notifications',
      settings.notificationsEnabled,
    );

    await prefs.setBool(
      'task15_worker_enabled',
      settings.workerEnabled,
    );
  }
}