import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/models/task18_models.dart';


class Task18RemoteException implements Exception {
  const Task18RemoteException( this.message, {
    this.statusCode, });

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class Task18RemoteDataSource {
  Task18RemoteDataSource({
    Dio? countryDio, Dio? weatherDio, })  : _countryDio = countryDio ?? Dio( BaseOptions( baseUrl:
                    'https://api.restcountries.com',
                connectTimeout: const Duration(seconds: 8), receiveTimeout: const Duration(seconds: 8),
                sendTimeout: const Duration(seconds: 8), ), ),
        _weatherDio = weatherDio ?? Dio( BaseOptions( baseUrl: 'https://api.openweathermap.org',
                connectTimeout: const Duration(seconds: 8), receiveTimeout: const Duration(seconds: 8),
                sendTimeout: const Duration(seconds: 8), ), );

  final Dio _countryDio;
  final Dio _weatherDio;

  //rest country
  Future<Task18Country> fetchCountry( String code, ) async {
    final key = dotenv.env['RESTCOUNTRIES_API_KEY'] ?.trim() ?? '';

    debugPrint( 'TASK18 RESTCOUNTRIES KEY LOADED: '
      '${key.isNotEmpty}', );

    if (key.isEmpty) {
      throw const Task18RemoteException( 'Thiếu RESTCOUNTRIES_API_KEY '
        'trong file .env.', );
    }

    final response = await _getWithBackoff( dio: _countryDio, path: '/countries/v5/codes.alpha_2/'
          '${code.toUpperCase()}',
      queryParameters: {
        'response_fields': 'names.common,'
            'codes.alpha_2,'
            'capitals,'
            'region,'
            'population,'
            'flag.url_png,'
            'currencies,'
            'calling_codes,'
            'timezones', },
      headers: {
        'Authorization': 'Bearer $key', },
      apiName: 'REST Countries', );

    debugPrint( 'TASK18 COUNTRY RAW: '
      '${response.data}', );

    if (response.data is! Map) {
      throw const Task18RemoteException( 'Dữ liệu quốc gia không hợp lệ.', );
    }

    final root = Map<String, dynamic>.from( response.data as Map, );

    final data = root['data'];

    if (data is! Map) {
      throw const Task18RemoteException( 'REST Countries không trả về '
        'khối data hợp lệ.', );
    }

    final dataMap = Map<String, dynamic>.from( data, );

    final objects = dataMap['objects'];

    if (objects is! List || objects.isEmpty) {
      throw const Task18RemoteException( 'Không tìm thấy quốc gia.', );
    }

    final first = objects.first;

    if (first is! Map) {
      throw const Task18RemoteException( 'Dữ liệu quốc gia '
        'không đúng định dạng.', );
    }

    final json = Map<String, dynamic>.from( first, );

    final country = Task18Country.fromApi( json, );

    debugPrint( 'TASK18 COUNTRY PARSED: '
      'name=${country.name}, '
      'code=${country.code}, '
      'capital=${country.capital}', );

    if (country.capital .trim() .isEmpty) {
      throw const Task18RemoteException( 'Không lấy được thủ đô '
        'của quốc gia.', );
    }

    return country;
  }

  // open weather
  Future<Task18Weather> fetchWeather( String capital, ) async {
    final normalizedCapital = capital.trim();

    if (normalizedCapital.isEmpty) {
      throw const Task18RemoteException( 'Tên thủ đô bị trống.', );
    }

    debugPrint( 'TASK18 WEATHER CAPITAL: '
      '$normalizedCapital', );

    final key = dotenv.env['OPENWEATHER_API_KEY'] ?.trim() ?? '';

    debugPrint( 'TASK18 OPENWEATHER KEY LOADED: '
      '${key.isNotEmpty}', );

    if (key.isEmpty) {
      throw const Task18RemoteException( 'Thiếu OPENWEATHER_API_KEY '
        'trong file .env.', );
    }

    final response = await _getWithBackoff( dio: _weatherDio, path: '/data/2.5/weather',
      queryParameters: {
        'q': normalizedCapital, 'appid': key, 'units': 'metric', 'lang': 'vi', },
      apiName: 'OpenWeather', );

    debugPrint( 'TASK18 WEATHER RAW: '
      '${response.data}', );

    if (response.data is! Map) {
      throw const Task18RemoteException( 'Dữ liệu thời tiết '
        'không hợp lệ.', );
    }

    final weather = Task18Weather.fromApi( Map<String, dynamic>.from( response.data as Map, ), );

    debugPrint( 'TASK18 WEATHER PARSED: '
      '${weather.city} | '
      '${weather.temperatureC}°C | '
      '${weather.description}', );

    return weather;
  }

  // retry,backoff
  Future<Response<dynamic>> _getWithBackoff({
    required Dio dio, required String path, required String apiName, Map<String, dynamic>?
        queryParameters,
    Map<String, dynamic>? headers, }) async {
    DioException? lastError;

    for ( var attempt = 0;
      attempt < 3;
      attempt++ ) {
      try {
        debugPrint( 'TASK18 API CALL: '
          '$apiName | '
          '${dio.options.baseUrl}$path | '
          'attempt=${attempt + 1}', );

        final response = await dio.get<dynamic>( path, queryParameters: queryParameters,
          options: Options( headers: headers, ), );

        debugPrint( 'TASK18 API SUCCESS: '
          '$apiName | '
          'status=${response.statusCode}', );

        return response;
      } on DioException catch (e) {
        lastError = e;

        final status = e.response?.statusCode;

        debugPrint( 'TASK18 API ERROR: '
          '$apiName | '
          'attempt=${attempt + 1} | '
          'status=$status | '
          'type=${e.type} | '
          'data=${e.response?.data}', );

        final retryableStatus = status == 429 || (status != null && status >= 500);

        final retryableNetwork = {
          DioExceptionType .connectionTimeout, DioExceptionType .receiveTimeout, DioExceptionType
              .sendTimeout,
          DioExceptionType .connectionError, }.contains(e.type);

        final canRetry = attempt < 2 && (retryableStatus || retryableNetwork);

        if (!canRetry) {
          break;
        }

        final waitSeconds = 2 << attempt;

        debugPrint( 'TASK18 RETRY: '
          '$apiName sau '
          '$waitSeconds giây...', );

        await Future<void>.delayed( Duration( seconds: waitSeconds, ), );
      }
    }

    final status = lastError ?.response ?.statusCode;

    final serverData = lastError ?.response ?.data;

    if (status == 400) {
      throw Task18RemoteException( '$apiName: yêu cầu '
        'không hợp lệ (400).', statusCode: status, );
    }

    if (status == 401) {
      throw Task18RemoteException( '$apiName: API key '
        'không hợp lệ hoặc '
        'chưa được kích hoạt (401).', statusCode: status, );
    }

    if (status == 403) {
      throw Task18RemoteException( '$apiName: không có quyền '
        'truy cập API (403).', statusCode: status, );
    }

    if (status == 404) {
      throw Task18RemoteException( '$apiName: không tìm thấy '
        'dữ liệu yêu cầu (404).', statusCode: status, );
    }

    if (status == 429) {
      throw Task18RemoteException( '$apiName: đã vượt giới hạn '
        'request. Vui lòng thử lại sau.', statusCode: status, );
    }

    if (status != null && status >= 500) {
      throw Task18RemoteException( '$apiName đang gặp lỗi '
        'máy chủ ($status). '
        'Vui lòng thử lại sau.', statusCode: status, );
    }

    if (lastError?.type == DioExceptionType .connectionTimeout || lastError?.type == DioExceptionType
                .receiveTimeout ||
        lastError?.type == DioExceptionType .sendTimeout) {
      throw const Task18RemoteException( 'Kết nối API quá thời gian. '
        'Vui lòng thử lại.', );
    }

    if (lastError?.type == DioExceptionType .connectionError) {
      throw const Task18RemoteException( 'Không thể kết nối mạng. '
        'Kiểm tra Internet '
        'và thử lại.', );
    }

    debugPrint( 'TASK18 FINAL API ERROR: '
      '$apiName | '
      '$serverData', );

    throw Task18RemoteException( '$apiName: không thể '
      'tải dữ liệu.', statusCode: status, );
  }
}
