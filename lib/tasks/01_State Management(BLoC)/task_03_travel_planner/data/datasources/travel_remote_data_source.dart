import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/models/country_model.dart';
import '../../domain/models/weather_model.dart';

class TravelApiException implements Exception {
  const TravelApiException(this.message,{this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString()=>message;
}

class TravelRemoteDataSource {
  TravelRemoteDataSource({Dio? dio})
      : _dio=dio ?? Dio(
          BaseOptions(
            connectTimeout:const Duration(seconds:8),
            receiveTimeout:const Duration(seconds:8),
            
            sendTimeout:const Duration(seconds:8),
          ),
        );

  final Dio _dio;

  // tải 4 q.gia lên trag đầu
 // nếu lỗi ă nc thì vẫn thử các nước còn lại
// if lỗi hết thì trả lỗi , k để list rỗng
Future<List<CountryModel>> loadFeaturedCountries() async {
  const names = ['Vietnam', 'Japan', 'France', 'South Korea'];

  final featured = <CountryModel>[];
  Object? firstError;

  for (final name in names) {
    try {
      final countries = await searchCountries(name);

      if (countries.isNotEmpty) {
        featured.add(countries.first);
      }
    } catch (error) {
      firstError ??= error;
      debugPrint('TASK 03 - Không tải được $name: $error');
    }
  }



  if (featured.isEmpty && firstError != null) {
    throw firstError;
  }
  return featured;
}

  // tìm theo tên quốc gia bằng v5 , k dùng v3,1
Future<List<CountryModel>> searchCountries(String query) async {
  final keyword = query.trim();

  if (keyword.isEmpty) {
    return [];
  }

  return _searchV5(keyword);
}


  Future<List<CountryModel>> _searchV5(String query) async {
  // dọc api key
  final apiKey = dotenv.env['RESTCOUNTRIES_API_KEY']?.trim() ?? '';

  if (apiKey.isEmpty) {
    throw const TravelApiException(
      'Thiếu RESTCOUNTRIES_API_KEY trong file .env.',
    );
  }

  final response = await _getWithRetry(
    apiName: 'REST Countries v5',
    uri: Uri.https(
      'api.restcountries.com',
      '/countries/v5/name',
      {
        'q': query,
        'limit': '50',
        'response_fields':
            'names,codes,capitals,region,subregion,population,'
            'flag,currencies,languages,timezones,coordinates',
      },
    ),
    headers: {
      'Authorization': 'Bearer $apiKey',
    },
  );


  if (response.data is! Map) {
    throw const TravelApiException(
      'REST Countries trả dữ liệu không đúng định dạng.',
    );
  }

  final root = Map<String, dynamic>.from(response.data as Map);
  final data = root['data'];

  if (data is! Map) {
    throw const TravelApiException(
      'Không tìm thấy phần data trong phản hồi API.',
    );
  }

  final objects = data['objects'];

  if (objects is! List) {
    throw const TravelApiException(
      'Không tìm thấy danh sách quốc gia trong phản hồi API.',
    );
  }

  // chuyển json của từng q.gia thành CountryModel
  final countries = objects
      .whereType<Map>()
      .map(
        (item) => CountryModel.fromV5(
          Map<String, dynamic>.from(item),
        ),
      )
      .where((country) => country.name.isNotEmpty)
      .toList();

  countries.sort((a, b) => a.name.compareTo(b.name));

  debugPrint(
    'TASK 03 - Tìm "$query": ${countries.length} quốc gia',
  );

  return countries;
}

  // gọi openweather để coi thời tiết.
  Future<WeatherModel> loadWeather(CountryModel country) async {
    final key=dotenv.env['OPENWEATHER_API_KEY']?.trim() ?? '';

    if(key.isEmpty) {
      throw const TravelApiException(
        'Thiếu OPENWEATHER_API_KEY trong file .env.',
      );
    }

    if(country.capital.trim().isEmpty) {
      throw const TravelApiException(
        'Quốc gia này không có dữ liệu thủ đô.',
      );
    }

    final place=country.code.isEmpty
        ? country.capital
        : '${country.capital},${country.code}';

    final current=await _getWithRetry(
      apiName:'OpenWeather Current',
      uri:Uri.https(
        'api.openweathermap.org',
        '/data/2.5/weather',
        {
          'q':place,
          'appid':key,
          'units':'metric',
          'lang':'vi',
        },
      ),
    );

    Map<String,dynamic>? forecastJson;

    try {
      final forecast=await _getWithRetry(
        apiName:'OpenWeather Forecast',
        uri:Uri.https(
          'api.openweathermap.org',
          '/data/2.5/forecast',
          {
            'q':place,
            'appid':key,
            'units':'metric',
            'lang':'vi',
            'cnt':'8',
          },
        ),
      );

      if(forecast.data is Map) {
        forecastJson=Map<String,dynamic>.from(forecast.data as Map);
      }
    } catch(e) {
      debugPrint('TASK3 FORECAST OPTIONAL ERROR: $e');
    }

    if(current.data is! Map) {
      throw const TravelApiException(
        'Dữ liệu thời tiết không hợp lệ.',
      );
    }

    return WeatherModel.fromApi(
      current:Map<String,dynamic>.from(current.data as Map),
      forecast:forecastJson,
    );
  }

  // retry tối đa 3l 
  // k retry lỗi 401,403,404 
  Future<Response<dynamic>> _getWithRetry({
    required String apiName,
    required Uri uri,
    Map<String,dynamic>? headers,
  }) async {
    DioException? lastError;

    for(var attempt=0;attempt<3;attempt++) {
      try {
        debugPrint('TASK3 API: $apiName attempt=${attempt+1}');

        return await _dio.getUri(
          uri,
          options:Options(headers:headers),
        );
      } on DioException catch(e) {
        lastError=e;

        final status=e.response?.statusCode;
        final retryStatus=status==429 || (status!=null && status>=500);

        final retryNetwork={
          DioExceptionType.connectionTimeout,
          DioExceptionType.receiveTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.connectionError,
        }.contains(e.type);

        final canRetry=attempt<2 && (retryStatus || retryNetwork);

        if(!canRetry) break;

        await Future<void>.delayed(
          Duration(seconds:1<<attempt),
        );
      }
    }

    final status=lastError?.response?.statusCode;

    if(status==401) {
      throw TravelApiException(
        '$apiName: API key không hợp lệ hoặc chưa kích hoạt.',
        statusCode:status,
      );
    }

    if(status==403) {
      throw TravelApiException(
        '$apiName: không có quyền truy cập.',
        statusCode:status,
      );
    }

    if(status==404) {
      throw TravelApiException(
        '$apiName: không tìm thấy dữ liệu.',
        statusCode:status,
      );
    }

    if(status==429) {
      throw TravelApiException(
        '$apiName: vượt giới hạn request. Hãy thử lại.',
        statusCode:status,
      );
    }

    if(status!=null && status>=500) {
      throw TravelApiException(
        '$apiName đang gặp lỗi máy chủ.',
        statusCode:status,
      );
    }

    throw TravelApiException(
      '$apiName: không thể kết nối máy chủ.',
      statusCode:status,
    );
  }
}