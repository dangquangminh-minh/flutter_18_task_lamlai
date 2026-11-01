

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/models/travel_country.dart';

class MotionPhotoRemoteDataSource {
  MotionPhotoRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;


  //tìm ảnh phù hợp vs qg
  Future<String?> searchHeroImage(
    TravelCountry country,
  ) async {
    final key =
        dotenv.env['UNSPLASH_ACCESS_KEY']?.trim() ?? '';

    if (key.isEmpty) {
      return null;
    }

    try {
      final response = await _dio.get(
        'https://api.unsplash.com/search/photos',
        queryParameters: {
          'query': '${country.name} travel landscape',
          'page': 1,
          'per_page': 1,
          'orientation': 'landscape',
        },
        options: Options(
          headers: {
            'Authorization': 'Client-ID $key',
          },
        ),
      );

      final data =
          Map<String, dynamic>.from(response.data);

      final results = data['results'] as List? ?? [];

      if (results.isEmpty) {
        return null;
      }

      final photo = Map<String, dynamic>.from(
        results.first,
      );

      final urls = Map<String, dynamic>.from(
        photo['urls'] ?? {},
      );

      return urls['regular']?.toString() ??
          urls['small']?.toString();
    } catch (_) {
      
      // unsplash lỗi sẽ fallback sang ảnh cờ
      return null;
    }
  }
}