

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/models/pixabay_photo.dart';

class PixabayRemoteDataSource {
  PixabayRemoteDataSource({required this._dio});

  final Dio _dio;

  // lấy ảnh theo từ khóa và trag h.tại
  Future<PixabayPhotoPage> getPhotos({
    required String query,
    required int page,
    int perPage = 20, // mỗi trag lấy tối đa 20 ảnh

  }) async {
    final apiKey = dotenv.env['PIXABAY_API_KEY'];// đọc api key

    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const PixabayException(
        'Chưa cấu hình PIXABAY_API_KEY trong file .env.',
      );
    }

    try {
      debugPrint('PIXABAY QUERY: $query');
      debugPrint('PIXABAY PAGE: $page');

      final response = await _dio.get( // gửi http get tới pĩabay
        'https://pixabay.com/api/',
        queryParameters: {
          'key': apiKey.trim(),
          'q': query,
          'page': page,
          'per_page': perPage,
          'image_type': 'photo',
          'safesearch': 'true',
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 12), //limit time nhận và gửi
          receiveTimeout: const Duration(seconds: 12),
        ),
      );

      debugPrint('PIXABAY STATUS: ${response.statusCode}');
      debugPrint('PIXABAY TYPE: ${response.data.runtimeType}');

      if (response.data is! Map) {
        throw const PixabayException(
          'Dữ liệu Pixabay không đúng định dạng.',
        );
      }

      final data = Map<String, dynamic>.from(response.data);
      final hits = data['hits'] as List? ?? [];

      debugPrint('PIXABAY HITS: ${hits.length}');

      return PixabayPhotoPage(
        total: (data['total'] as num?)?.toInt() ?? 0,
        totalHits: (data['totalHits'] as num?)?.toInt() ?? 0,
        photos: hits.map((item) {
          return PixabayPhoto.fromJson(
            Map<String, dynamic>.from(item),
          );
        }).toList(),
      );
    } on DioException catch (e) {
  final status = e.response?.statusCode;

  debugPrint('PIXABAY STATUS: $status');
  debugPrint('PIXABAY TYPE: ${e.type}');

  if (status == 429) {// request bị giới hạn or từ chối
    throw const PixabayException(
      'Pixabay đang từ chối request từ ứng dụng. Vui lòng thử lại sau.',
    );
  }

  if (status == 400) { // k  h.lệ
    throw const PixabayException(
      'Request Pixabay không hợp lệ.',
    );
  }

  if (status == 401 || status == 403) { // lq đến quyền sd api
    throw const PixabayException(
      'Pixabay API key không hợp lệ hoặc bị từ chối.',
    );
  }

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    throw const PixabayException(
      'Kết nối Pixabay quá thời gian.',
    );
  }

  if (e.type == DioExceptionType.connectionError) {
    throw const PixabayException(
      'Không có kết nối Internet.',
    );
  }

  throw const PixabayException(
    'Không tải được ảnh từ Pixabay.',
  );
} catch (e, stackTrace) {
      debugPrint('PIXABAY PARSE ERROR: $e');
      debugPrint('$stackTrace');

      throw const PixabayException(
        'Không thể xử lý dữ liệu ảnh từ Pixabay.',
      );
    }
  }
}

class PixabayException implements Exception {
  const PixabayException(this.message);

  final String message;

  @override
  String toString() => message;
}