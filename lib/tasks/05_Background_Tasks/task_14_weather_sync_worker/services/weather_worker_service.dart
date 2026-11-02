
import 'package:dio/dio.dart';
import 'package:workmanager/workmanager.dart';

import '../data/datasources/weather_local_data_source.dart';
import '../data/datasources/weather_remote_data_source.dart';
import '../data/repositories/weather_sync_repository.dart';
import '../domain/models/weather_sync_event.dart';
import '../domain/models/weather_sync_settings.dart';
import 'weather_alert_notification_service.dart';

const weatherPeriodicUniqueName = 'task14_weather_periodic_unique';

const weatherPeriodicTaskName =  'task14_weather_periodic';

const weatherOneOffTaskName ='task14_weather_one_off';


class WeatherWorkerExecutor {
  // đọc inputData do WorkManager truyền
  static Future<bool> execute({
    required String taskName,
    required Map<String, dynamic> inputData,
  }) async {
    final local =  WeatherLocalDataSource();

    try {
      final apiKey =inputData['apiKey'] ?.toString() ??
              '';

      // mã thành phố được gửi từ UI lúc đăng ký
      final cityKey =inputData['cityKey'] ?.toString() ??
              'hcm';

      final threshold =(inputData['threshold'] as num?)?.toDouble() ??
              34;

      final alertEnabled =inputData['alertEnabled'] == true;

      final city =WeatherCity.byKey(cityKey,);

      final source =taskName == weatherPeriodicTaskName
              ? 'periodic-worker'
              : 'one-off-worker';

      final repository =WeatherSyncRepository(
        local: local,
        remote:
            WeatherRemoteDataSource(
          dio: Dio(),
        ),
      );

      final snapshot =await repository.sync(
        city: city,
        apiKey: apiKey,
        source: source,
      );


      // check ng nh.độ
      if (alertEnabled &&snapshot.temperature > threshold) {
        final lastAlert = await local.getLastAlertAt();

        // k/c tối thiểu hai giờ giữa hai cảnh báo giúp tránh gửi lặp liên tục
        final canNotify =
            lastAlert == null || DateTime.now() .difference( lastAlert,)
                        .inHours >=
                    2;

        if (canNotify) {
          try {
            await WeatherAlertNotificationService
                .showHeatAlert(
              snapshot: snapshot,
              threshold:
                  threshold,
            );

            await local
                .saveLastAlertAt(
              DateTime.now(),
            );

            await local.addEvent(
              WeatherSyncEvent(
                type: 'alert',
                message:
                    '${snapshot.cityName}: '
                    '${snapshot.temperature.toStringAsFixed(1)}°C '
                    '> '
                    '${threshold.toStringAsFixed(0)}°C',
                createdAt:
                    DateTime.now(),
                success: true,
              ),
            );
          } catch (e) {
            // Notification lỗi không được
            // làm thất bại toàn bộ weather sync.
            await local.addEvent(
              WeatherSyncEvent(
                type:
                    'notification_error',
                message:
                    'Không thể phát '
                    'cảnh báo: $e',
                createdAt:
                    DateTime.now(),
                success: false,
              ),
            );
          }
        }
      }

      return true;

    } on WeatherSyncException catch (e) {
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

      if (e.retryable) {

        return false;
      }

      // lỗi vĩnh viễn:
      // ví dụ API key sai
      // Không retry vô hạn
      throw Exception(
        e.message,
      );
    } catch (e) {
      await local.saveLastError(
        e.toString(),
      );

      await local.addEvent(
        WeatherSyncEvent(
          type: 'error',
          message:
              e.toString(),
          createdAt:
              DateTime.now(),
          success: false,
        ),
      );

      // Lỗi không xác định:
      // cho WorkManager retry
      return false;
    }
  }
}


class WeatherWorkerManager {
  WeatherWorkerManager._();


  // chuẩn hóa api key, mã thành phố và ngưỡng để background isolate có đủ tham số
  static Map<String, dynamic> _input({
    required WeatherSyncSettings settings,
    required String apiKey,
  }) {
    return {
      'apiKey': apiKey,
      'cityKey':
          settings.cityKey,
      'threshold':
          settings.thresholdC,
      'alertEnabled':
          settings.alertEnabled,
    };
  }


  // ánh xạ lựa chọn Wi-Fi/sạc/pin của UI sang điều kiện mà Android có thể áp dụng.
  static Constraints _constraints(
    WeatherSyncSettings settings,
  ) {
    return Constraints(
      networkType:
          settings.wifiOnly
              ? NetworkType.unmetered
              : NetworkType.connected,

      requiresCharging:
          settings.chargingOnly,

      requiresBatteryNotLow:
          settings.batteryNotLow,

      requiresDeviceIdle:
          false,

      requiresStorageNotLow:
          true,
    );
  }


  // Đăng ký periodic task với unique name, tránh tạo nhiều lịch giống nhau
  static Future<void> registerPeriodic({
    required WeatherSyncSettings settings,
    required String apiKey,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception(
        'OPENWEATHER_API_KEY '
        'chưa được cấu hình.',
      );
    }

    final minutes =
        settings.intervalMinutes < 15
            ? 15
            : settings.intervalMinutes;

    final frequency =
        Duration(
      minutes: minutes,
    );

    await Workmanager()
        .registerPeriodicTask(
      weatherPeriodicUniqueName,
      weatherPeriodicTaskName,

      frequency:
          frequency,

      inputData:
          _input(
        settings: settings,
        apiKey: apiKey,
      ),

      constraints:
          _constraints(
        settings,
      ),

      existingWorkPolicy:
          ExistingPeriodicWorkPolicy
              .update,

      backoffPolicy:
          BackoffPolicy.exponential,

      backoffPolicyDelay:
          const Duration(
        seconds: 30,
      ),

      tag:
          'task14-weather-sync',
    );
  }


  // gửi một job chạy nền một lần để test worker mà không đợi chu kỳ định kỳ
  static Future<void> runOneOff({
    required WeatherSyncSettings settings,
    required String apiKey,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception(
        'OPENWEATHER_API_KEY '
        'chưa được cấu hình.',
      );
    }

    final uniqueName =
        'task14_manual_'
        '${DateTime.now().millisecondsSinceEpoch}';

    await Workmanager()
        .registerOneOffTask(
      uniqueName,
      weatherOneOffTaskName,

      inputData:
          _input(
        settings: settings,
        apiKey: apiKey,
      ),

      constraints:
          _constraints(
        settings,
      ),

      existingWorkPolicy:
          ExistingWorkPolicy.replace,

      backoffPolicy:
          BackoffPolicy.exponential,

      backoffPolicyDelay:
          const Duration(
        seconds: 30,
      ),

      tag:
          'task14-weather-manual',
    );
  }


  static Future<void> cancelPeriodic() {
    return Workmanager()
        .cancelByUniqueName(
      weatherPeriodicUniqueName,
    );
  }
}