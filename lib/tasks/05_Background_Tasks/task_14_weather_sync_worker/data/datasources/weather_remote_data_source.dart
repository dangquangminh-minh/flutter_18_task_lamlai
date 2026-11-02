
import 'package:dio/dio.dart';

import '../../domain/models/weather_snapshot.dart';
import '../../domain/models/weather_sync_settings.dart';


class WeatherSyncException
    implements Exception {
  const WeatherSyncException(
    this.message, {
    required this.retryable,
  });

  final String message;
  final bool retryable;

  @override
  String toString() => message;
}


class WeatherRemoteDataSource {
  WeatherRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;


  Future<WeatherSnapshot> fetchWeather({
    required WeatherCity city,
    required String apiKey,
    required String source,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const WeatherSyncException(
        'OPENWEATHER_API_KEY chưa được cấu hình.',
        retryable: false,
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.openweathermap.org'
        '/data/2.5/weather',
        queryParameters: {
          'q': city.query,
          'appid': apiKey,
          'units': 'metric',
          'lang': 'vi',
        },
        options: Options(
          sendTimeout:
              const Duration(seconds: 8),
          receiveTimeout:
              const Duration(seconds: 8),
          validateStatus: (_) => true,
        ),
      );

      final status = response.statusCode ?? 0;

      if (status == 401 || status == 403) {
        throw const WeatherSyncException(
          'OpenWeather API key không hợp lệ '
          'hoặc chưa được kích hoạt.',
          retryable: false,
        );
      }

      if (status == 404) {
        throw WeatherSyncException(
          'Không tìm thấy thành phố '
          '${city.label}.',
          retryable: false,
        );
      }

      if (status == 408 || status == 429 ||status >= 500) {
        throw WeatherSyncException(
          'OpenWeather tạm thời không khả dụng '
          '(HTTP $status).',
          retryable: true,
        );
      }

      if (status < 200 ||status >= 300 ||
          response.data == null) {
        throw WeatherSyncException(
          'OpenWeather trả về HTTP $status.',
          retryable: false,
        );
      }

      return WeatherSnapshot.fromApi(
        json: response.data!,
        city: city,
        source: source,
      );
    } on WeatherSyncException {
      rethrow;
    } on DioException catch (e) {
      final retryable = e.type == DioExceptionType.connectionTimeout ||e.type == DioExceptionType.receiveTimeout ||e.type == DioExceptionType.sendTimeout ||e.type ==DioExceptionType.connectionError ||e.type ==DioExceptionType.unknown;

      throw WeatherSyncException(
        retryable
            ? 'Không thể kết nối OpenWeather. '
                'Worker sẽ thử lại.'
            : 'Lỗi OpenWeather: ${e.message}',
        retryable: retryable,
      );
    } catch (e) {
      throw WeatherSyncException(
        'Không thể đồng bộ thời tiết: $e',
        retryable: true,
      );
    }
  }
}