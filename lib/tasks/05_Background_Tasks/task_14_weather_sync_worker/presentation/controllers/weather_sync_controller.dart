

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../data/datasources/weather_local_data_source.dart';
import '../../data/datasources/weather_remote_data_source.dart';
import '../../data/repositories/weather_sync_repository.dart';

import '../../domain/models/weather_snapshot.dart';
import '../../domain/models/weather_sync_event.dart';

import '../../domain/models/weather_sync_settings.dart';
import '../../services/weather_alert_notification_service.dart';
import '../../services/weather_worker_service.dart';


enum WeatherSyncStatus {
  loading,
  ready,
  syncing,
  error,
}


class WeatherSyncController
    extends ChangeNotifier {
  WeatherSyncController({
    required this.apiKey,
  }) {
    local = WeatherLocalDataSource();

    repository =WeatherSyncRepository(

      local: local,
      remote:
          WeatherRemoteDataSource(
        dio: Dio(),
      ),
    );
  }

  final String apiKey;

  late final WeatherLocalDataSource local;
  late final WeatherSyncRepository repository;

  WeatherSyncStatus status =  WeatherSyncStatus.loading;

  WeatherSyncSettings settings =  WeatherSyncSettings.defaults();
  Map<String, WeatherSnapshot> snapshots ={};


  List<WeatherSyncEvent> history =[];

  String? lastError;
  String? feedback;

  WeatherSnapshot? get selectedSnapshot =>
      snapshots[settings.cityKey];

  // đọc cấu hình worker và cache khi vào trang
  Future<void> initialize() async {
    status = WeatherSyncStatus.loading;

    notifyListeners();
    settings =await local.loadSettings();

    await reloadCache();

    status =WeatherSyncStatus.ready;

    notifyListeners();
  }

  // tải lại dl đã lưu
  Future<void> reloadCache() async {
    snapshots = await repository.getSnapshots();

    history =await repository.getHistory();

    lastError = await repository.getLastError();
    notifyListeners();
  }


  Future<void> setCity(
    String cityKey,
  ) async {
    settings = settings.copyWith(
      cityKey: cityKey,
    );

    await _saveAndUpdateWorker();

    notifyListeners();
  }

  // chọn chu kỳ worker
  Future<void> setInterval(
    int minutes,
  ) async {
    settings = settings.copyWith(
      intervalMinutes: minutes,
    );

    await _saveAndUpdateWorker();

    notifyListeners();
  }

  // ràng buộc chỉ chạy khi có Wi-Fi
  Future<void> setWifiOnly(
    bool value,
  ) async {
    settings = settings.copyWith(
      wifiOnly: value,
    );

    await _saveAndUpdateWorker();

    notifyListeners();
  }


  Future<void> setChargingOnly(
    bool value,
  ) async {
    settings =
        settings.copyWith(
      chargingOnly: value,
    );

    await _saveAndUpdateWorker();

    notifyListeners();
  }


  Future<void> setBatteryNotLow(
    bool value,
  ) async {
    settings =
        settings.copyWith(
      batteryNotLow: value,
    );

    await _saveAndUpdateWorker();

    notifyListeners();
  }

  // lưu ngưỡng nhiệt độ
  Future<void> setThreshold(
    double value,
  ) async {
    settings = settings.copyWith(
      thresholdC: value,
    );


    await _saveAndUpdateWorker();
    notifyListeners();
  }

  // bật/tắt cảnh báo và kiểm tra quyền t.báo
  Future<bool> setAlertEnabled(
    bool value,
  ) async {
    if (value) {
      final granted =  await WeatherAlertNotificationService.requestAndroidPermission();

      if (!granted) {
        feedback = 'Chưa được cấp quyền thông báo.';

        notifyListeners();

        return false;
      }
    }

    settings =
        settings.copyWith(
      alertEnabled: value,
    );

    await _saveAndUpdateWorker();

    notifyListeners();

    return true;
  }


  Future<bool> registerWorker() async {
    if (apiKey.trim().isEmpty) {
      feedback ='Bạn chưa cấu hình ''OPENWEATHER_API_KEY trong .env.';

      notifyListeners();
      return false;
    }

    try {
      if (settings.alertEnabled) {
        final permission =
            await WeatherAlertNotificationService
                .requestAndroidPermission();

        if (!permission) {
          feedback =
              'Worker vẫn có thể sync, '
              'nhưng notification chưa được cấp quyền.';
        }
      }

      await WeatherWorkerManager
          .registerPeriodic(
        settings: settings,
        apiKey: apiKey,
      );

      settings =settings.copyWith( workerEnabled: true,
      );

      await local.saveSettings(settings,
      );

      await local.addEvent(
        WeatherSyncEvent(
          type: 'worker',
          message:
              'Đã đăng ký worker '
              '${settings.intervalMinutes} phút.',
          createdAt:
              DateTime.now(),
          success: true,
        ),
      );

      feedback =
          'Background Worker đã được đăng ký.';

      await reloadCache();

      return true;
    } catch (e) {
      feedback =
          'Không thể đăng ký Worker: $e';

      notifyListeners();
      return false;
    }
  }

  // hủy worker định kỳ theo unique name
  Future<void> cancelWorker() async {
    await WeatherWorkerManager
        .cancelPeriodic();

    settings = settings.copyWith(workerEnabled: false,
    );

    await local.saveSettings(
      settings,
    );

    await local.addEvent(
      WeatherSyncEvent(
        type: 'worker',
        message:
            'Đã tắt Background Worker.',
        createdAt:
            DateTime.now(),
        success: true,
      ),
    );

    feedback = 'Đã hủy worker định kỳ.';

    await reloadCache();
  }

  // đồng bộ thủ công trên màn hình để nhận dl ngay
  Future<void> syncNow() async {
    if (apiKey.trim().isEmpty) {
      feedback ='Thiếu OPENWEATHER_API_KEY.';

      notifyListeners();
      return;
    }

    status = WeatherSyncStatus.syncing;

    feedback = null;

    notifyListeners();

    try {
      final snapshot =
          await repository.sync(
        city: settings.city,
        apiKey: apiKey,
        source: 'foreground',
      );

      if (settings.alertEnabled &&
          snapshot.temperature >
              settings.thresholdC) {
        await _tryAlert(snapshot);
      }

      lastError = null;

      feedback =
          'Đồng bộ thành công '
          '${snapshot.temperature.toStringAsFixed(1)}°C.';
    } on WeatherSyncException catch (e) {
      lastError = e.message;

      await local.saveLastError(
        e.message,
      );

      await local.addEvent(
        WeatherSyncEvent(
          type: 'error',
          message: e.message,
          createdAt:
              DateTime.now(),
          success: false,
        ),
      );

      feedback = e.message;
    } finally {
      status =
          WeatherSyncStatus.ready;

      await reloadCache();

      notifyListeners();
    }
  }

  Future<void> testOneOffWorker() async {
    if (apiKey.trim().isEmpty) {
      feedback ='Thiếu OPENWEATHER_API_KEY.';

      notifyListeners();
      return;
    }

    status =
        WeatherSyncStatus.syncing;

    feedback =
        'Đã gửi One-off Worker vào WorkManager...';

    notifyListeners();

    final before =
        selectedSnapshot?.syncedAt;

    try {
      await WeatherWorkerManager.runOneOff(
        settings: settings,
        apiKey: apiKey,
      );

      for (int i = 0; i < 15; i++) {
        await Future<void>.delayed(
          const Duration(seconds: 1),
        );

        await reloadCache();

        final after =
            selectedSnapshot?.syncedAt;

        if (after != null && (before == null ||
                after.isAfter(before))) {
          feedback =
              'One-off Worker đã chạy '
              'và lưu snapshot vào Hive.';

          status =
              WeatherSyncStatus.ready;

          notifyListeners();

          return;
        }
      }

      feedback =
          'Worker đã được enqueue. '
          'Android có thể trì hoãn thời điểm chạy.';
    } catch (e) {
      feedback =
          'Không thể chạy One-off Worker: $e';
    }

    status =
        WeatherSyncStatus.ready;

    notifyListeners();
  }

  // sau khi có dl, kiểm tra ngưỡng và thời điểm cảnh báo cuối cùng để hạn chế spam
  Future<void> _tryAlert(
    WeatherSnapshot snapshot,
  ) async {
    final last =
        await local.getLastAlertAt();

    if (last != null &&
        DateTime.now()
                .difference(last)
                .inHours <
            2) {
      return;
    }

    final permission =await WeatherAlertNotificationService.requestAndroidPermission();

    if (!permission) {
      return;
    }

    await WeatherAlertNotificationService.showHeatAlert(
      snapshot: snapshot,
      threshold:
          settings.thresholdC,
    );

    await local.saveLastAlertAt(
      DateTime.now(),
    );

    await local.addEvent(
      WeatherSyncEvent(
        type: 'alert',
        message:
            '${snapshot.cityName}: '
            '${snapshot.temperature.toStringAsFixed(1)}°C '
            '> ${settings.thresholdC.toStringAsFixed(0)}°C',
        createdAt:
            DateTime.now(),
        success: true,
      ),
    );
  }

  // lưu cấu hình rồi cập nhật lịch worker đang bật
  Future<void> _saveAndUpdateWorker() async {
    await local.saveSettings(settings,
    );

    if (settings.workerEnabled &&  apiKey.trim().isNotEmpty) {
      await WeatherWorkerManager
          .registerPeriodic(
        settings: settings,
        apiKey: apiKey,
      );
    }
  }
}