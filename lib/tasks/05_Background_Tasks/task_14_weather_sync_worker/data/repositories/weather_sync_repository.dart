

import '../../domain/models/weather_snapshot.dart';
import '../../domain/models/weather_sync_event.dart';
import '../../domain/models/weather_sync_settings.dart';

import '../datasources/weather_local_data_source.dart';
import '../datasources/weather_remote_data_source.dart';


class WeatherSyncRepository {
  WeatherSyncRepository({
    required WeatherLocalDataSource local,
    required WeatherRemoteDataSource remote,
  }) : _local = local,
       _remote = remote;

  final WeatherLocalDataSource _local;

  final WeatherRemoteDataSource _remote;

  // tải thời tiết mới,lưu snapshot và sự kiện t.công; báo lỗi
  Future<WeatherSnapshot> sync({
    required WeatherCity city,
    required String apiKey,
    required String source,
  }) async {
    final snapshot =  await _remote.fetchWeather(
      city: city,
      apiKey: apiKey,
      source: source,
    );

    await _local.saveSnapshot(snapshot);

    await _local.addEvent(
      
      WeatherSyncEvent(
        type: 'sync',
        message:
            '${city.label}: '
            '${snapshot.temperature.toStringAsFixed(1)}°C '
            '• $source',
        createdAt: DateTime.now(),
        success: true,
      ),
    );

    return snapshot;
  }

  Future<Map<String, WeatherSnapshot>>
      getSnapshots() {
    return _local.getSnapshots();
  }

  Future<List<WeatherSyncEvent>>
      getHistory() {
    return _local.getHistory();
  }

  // ui lấy lỗi gần nhất từ local cache để t.hiện lý do đồng bộ thất bại
  Future<String?> getLastError() {
    return _local.getLastError();
  }
}