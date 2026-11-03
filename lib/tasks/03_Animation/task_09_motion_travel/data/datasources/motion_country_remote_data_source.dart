

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/travel_country.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class MotionCountryRemoteDataSource {
  MotionCountryRemoteDataSource({
    required this._dio,
  });

  final Dio _dio;

  // gọi api lấy ds qg
  Future<List<TravelCountry>> getCountries() async {
  final key =
      dotenv.env['RESTCOUNTRIES_API_KEY']?.trim() ?? '';

  if (key.isEmpty) {
    throw Exception(
      'Chưa cấu hình RESTCOUNTRIES_API_KEY trong .env',
    );
  }

  try {
    final countries = <TravelCountry>[];

    const limit = 100; // lấy max 100 qg

    int offset = 0;

    while (true) {
      final response = await _dio.get(
        'https://api.restcountries.com/countries/v5',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'response_fields':
          'names.common,names.official,'
          'codes.alpha_2,capitals,region,subregion,'
          'population,currencies,languages,timezones,'

          'flag.url_png,flag.url_svg,'
          
          'coordinates.lat,coordinates.lng',
        },
        options: Options(
          headers: {     // gửi api key để xác thực
            'Authorization': 'Bearer $key',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15), // limit
        ),
      );

      debugPrint(
        'TASK9 COUNTRY STATUS: ${response.statusCode}',
      );

      final root = Map<String, dynamic>.from(
        response.data,
      );

      final errors = root['errors'];

      if (errors is List && errors.isNotEmpty) {
        throw Exception(
          'RestCountries báo lỗi: $errors',
        );
      }

      final data = Map<String, dynamic>.from(
        root['data'] ?? {},
      );

      final objects = data['objects'] as List? ?? []; // chứa ds qg cảu trag h.tại

      for (final item in objects) {
        countries.add(
          TravelCountry.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
      }

      final meta = Map<String, dynamic>.from(
        data['meta'] ?? {},
      );

      final more = meta['more'] == true;

      debugPrint(
        'TASK9 OFFSET $offset: ${objects.length} quốc gia',
      );

      if (!more) {    // nếu lấy hết thì dừng
        break;
      }

      offset += limit;   // chuyển qua 100 qg t.theo
    }

    countries.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    debugPrint(
      'TASK9 COUNTRIES PARSED: ${countries.length}',
    );

    return countries;
  } on DioException catch (e) {
    debugPrint(
      'TASK9 COUNTRY HTTP ERROR: '
      '${e.response?.statusCode}',
    );

    debugPrint(
      'TASK9 COUNTRY ERROR: ${e.response?.data}',
    );

    rethrow;
  }
}
}