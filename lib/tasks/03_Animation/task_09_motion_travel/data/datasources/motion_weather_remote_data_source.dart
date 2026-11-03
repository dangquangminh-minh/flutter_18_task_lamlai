

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/models/travel_weather.dart';

class MotionWeatherRemoteDataSource {
  MotionWeatherRemoteDataSource({required this._dio});

  final Dio _dio;

  //lấy weather h.tại dựa trên tp
  Future<TravelWeather> getWeather(String city) async {
    final key =
        dotenv.env['OPENWEATHER_API_KEY']?.trim() ?? '';

    if (key.isEmpty) {
      throw Exception('Thiếu OPENWEATHER_API_KEY.');
    }

    final response = await _dio.get(   // gửi request lấy 
      'https://api.openweathermap.org/data/2.5/weather',
      queryParameters: {
        'q': city,
        'appid': key,
        'units': 'metric',
        'lang': 'vi',
      },
    );

    return TravelWeather.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}