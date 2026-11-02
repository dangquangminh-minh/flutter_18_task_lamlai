
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/weather_snapshot.dart';
import '../../domain/models/weather_sync_event.dart';

import '../../domain/models/weather_sync_settings.dart';


class WeatherLocalDataSource {
  static const _boxName ='task14_weather_cache_box';

  static const _snapshotsKey =  'weather_snapshots';

  static const _historyKey ='weather_sync_history';
  static const _lastErrorKey ='weather_last_error'; // lỗi gần nhất

  static const _lastAlertKey = 'weather_last_alert';

  Future<WeatherSyncSettings>
      // k.phục t.phố, chu kỳ và ràng buộc hệ thống từ hive
      loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final defaults =  WeatherSyncSettings.defaults();

    return WeatherSyncSettings(
      cityKey:
          prefs.getString('task14_city') ?? defaults.cityKey,
      intervalMinutes:
          prefs.getInt('task14_interval') ?? defaults.intervalMinutes,
      wifiOnly:
          prefs.getBool('task14_wifi_only') ?? defaults.wifiOnly,
      chargingOnly:
          prefs.getBool( 'task14_charging_only',) ?? defaults.chargingOnly,
      batteryNotLow:
          prefs.getBool( 'task14_battery_not_low', ) ?? defaults.batteryNotLow,
      
      alertEnabled:
          prefs.getBool( 'task14_alert_enabled', ) ?? defaults.alertEnabled,
      thresholdC:
          prefs.getDouble('task14_threshold', ) ?? defaults.thresholdC,
      workerEnabled:
          prefs.getBool( 'task14_worker_enabled', ) ?? defaults.workerEnabled,
    );
  }

  // ghi c.hình ng.dùng để worker có thể dùng sau khi app khởi động 
  Future<void> saveSettings(
    WeatherSyncSettings settings,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'task14_city',
      settings.cityKey,
    );

    await prefs.setInt(
      'task14_interval',
      settings.intervalMinutes,
    );

    await prefs.setBool(
      'task14_wifi_only',
      settings.wifiOnly,
    );

    await prefs.setBool(
      'task14_charging_only',
      settings.chargingOnly,
    );

    await prefs.setBool(
      'task14_battery_not_low',
      settings.batteryNotLow,
    );

    await prefs.setBool(
      'task14_alert_enabled',
      settings.alertEnabled,
    );

    await prefs.setDouble(
      'task14_threshold',
      settings.thresholdC,
    );

    await prefs.setBool(
      'task14_worker_enabled',
      settings.workerEnabled,
    );
  }

  // mở hộp hive theo tên cố định
  Future<Box<dynamic>> _openBox() {
    return Hive.openBox<dynamic>(
      _boxName,
    );
  }

  // lưu snapshot thời tiết mới nhất và l.sử để h.thị lại khi offl
  Future<void> saveSnapshot(
    WeatherSnapshot snapshot,
  ) async {
    final box = await _openBox();

    try {
      final raw =  box.get(_snapshotsKey);

      final snapshots =  raw is Map
              ? Map<String, dynamic>.from(raw)
              : <String, dynamic>{};

      snapshots[snapshot.cityKey] = snapshot.toMap();

      await box.put(
        _snapshotsKey,
        snapshots,
      );

      await box.delete(
        _lastErrorKey,
      );
    } finally {
      await box.close();
    }
  }

  Future<Map<String, WeatherSnapshot>>
      getSnapshots() async {
    final box = await _openBox();

    try {
      final raw = box.get(_snapshotsKey);

      if (raw is! Map) {
        return {};
      }

      final result =  <String, WeatherSnapshot>{};

      for (final entry in raw.entries) {
        if (entry.value is Map) {
          result[entry.key.toString()] =
              WeatherSnapshot.fromMap(
            entry.value as Map,
          );
        }
      }

      return result;
    } finally {
      await box.close();
    }
  }

  // ghi lỗi đồng bộ gần nhất cho ui h.thị
  Future<void> saveLastError(
    String message,
  ) async {
    final box = await _openBox();

    try {
      await box.put(
        _lastErrorKey,
        message,
      );
    } finally {
      await box.close();
    }
  }


  Future<String?> getLastError() async {
    final box = await _openBox();

    try {
      return box
          .get(_lastErrorKey)
          ?.toString();
    } finally {
      await box.close();
    }
  }

  // thêm bản ghi h.động hoặc lỗi vào l.sử kiểm thử worker
  Future<void> addEvent(
    WeatherSyncEvent event,
  ) async {
    final box = await _openBox();

    try {
      final raw =  box.get(_historyKey);

      final list =  raw is List
              ? List<dynamic>.from(raw)
              : <dynamic>[];

      list.insert(
        0,
        event.toMap(),
      );

      if (list.length > 50) {
        list.removeRange(
          50,
          list.length,
        );
      }

      await box.put(
        _historyKey,
        list,
      );
    } finally {
      await box.close();
    }
  }

  Future<List<WeatherSyncEvent>>
      getHistory() async {
    final box = await _openBox();

    try {
      final raw =  box.get(_historyKey);

      if (raw is! List) {
        return [];
      }

      return raw
          .whereType<Map>()
          .map(
            WeatherSyncEvent.fromMap,
          )
          .toList();
    } finally {
      await box.close();
    }
  }

  // Đọc thời điểm cảnh báo gần nhất để hạn chế spam notification nhiệt độ cao.
  Future<DateTime?> getLastAlertAt() async {
    final box = await _openBox();

    try {
      final raw =  box.get(_lastAlertKey);

      return DateTime.tryParse(
        raw?.toString() ?? '',
      );
    } finally {
      await box.close();
    }
  }

  // lưu lần cảnh báo cuối cùng
  Future<void> saveLastAlertAt(
    DateTime value,
  ) async {
    final box = await _openBox();

    try {
      await box.put(
        _lastAlertKey,
        value.toIso8601String(),
      );
    } finally {
      await box.close();
    }
  }
}