import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/models/weather_models.dart';

// các loại lỗi 
enum WeatherErrorType {
  cityNotFound,
  unauthorized,
  timeout,
  offline,
  config,
  unknown,
}


class WeatherException implements Exception {
  WeatherException(

    this.message, {
    this.type = WeatherErrorType.unknown,
  });

  final String message;
  final WeatherErrorType type;

  @override
  String toString() => message;
}

class WeatherRemoteDataSource {
  WeatherRemoteDataSource({required this._dio});

  final Dio _dio;

  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5';

  // láy key
  String get _apiKey {
    final key = dotenv.env['OPENWEATHER_API_KEY'];

    if (key == null || key.trim().isEmpty) {
      throw WeatherException(
        'Chưa cấu hình OPENWEATHER_API_KEY trong file .env.',
        type: WeatherErrorType.config,
      );
    }

    return key;
  }


  Future<CurrentWeather> getCurrentByCity(String city) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'q': city,
          'appid': _apiKey,

          'units': 'metric',
          'lang': 'vi',
        },
      );

      return CurrentWeather.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }


  Future<List<ForecastItem>> getForecastByCity(String city) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast',
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'vi',
        },
      );

      return _parseForecast(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  // c.năng GPS 
  Future<CurrentWeather> getCurrentByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'vi',
        },
      );

      return CurrentWeather.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<List<ForecastItem>> getForecastByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'vi',
        },
      );

      return _parseForecast(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  // đọc timezone của thành phố rồi truyền vào từng bản ghi dự báo
  List<ForecastItem> _parseForecast(Map<String, dynamic> json) {
    final city = Map<String, dynamic>.from(json['city'] ?? {});
    final timezone = (city['timezone'] as num?)?.toInt() ?? 0;
    final list = json['list'] as List? ?? [];

    return list.map((item) {
      return ForecastItem.fromJson(
        Map<String, dynamic>.from(item),
        timezoneOffset: timezone,
      );
    }).toList();
  }


  WeatherException _mapDioException(DioException e) {
    final status = e.response?.statusCode;


    if (status == 404) {
      return WeatherException(
        'Không tìm thấy thành phố. Hãy kiểm tra lại tên.',
        type: WeatherErrorType.cityNotFound,
      );
    }

    // lỗi xác thực api key
    if (status == 401) {
      return WeatherException(
        'API key không hợp lệ hoặc chưa được kích hoạt.',
        type: WeatherErrorType.unauthorized,
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||e.type == DioExceptionType.receiveTimeout ||   e.type == DioExceptionType.sendTimeout) {
      return WeatherException(
        'Kết nối đến  máy chủ quá thời gian.',
        type: WeatherErrorType.timeout,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return WeatherException(
        'Không có kết nối Internet.',
        
        type: WeatherErrorType.offline,
      );
    }

    return WeatherException('Không thể tải dữ liệu thời tiết.');
  }
}