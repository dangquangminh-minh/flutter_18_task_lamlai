

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CampaignNotFoundException
    implements Exception {}

class CampaignRequestException
    implements Exception {
  const CampaignRequestException(
    this.message,
  );

  final String message;

  @override
  String toString() => message;
}

class CampaignPhoto {
  const CampaignPhoto({
    required this.url,
    required this.photographer,
    required this.photographerUrl,
  });

  final String url;
  final String photographer;
  final String photographerUrl;
}

class CampaignRemoteDataSource {
  CampaignRemoteDataSource({
    required this._dio,
  });

  final Dio _dio;

  // thử 3l khi 429,5xx
  Future<T> _retry<T>(
    Future<T> Function() request,
  ) async {
    for (int attempt = 0;
        attempt < 3;
        attempt++) {
      try {
        return await request();
      } on DioException catch (e) {
        final status =
            e.response?.statusCode ?? 0;

        // chỉ lặp lại lỗi có thể tạm thời

        final retryable =
            e.type ==
                    DioExceptionType.connectionTimeout ||e.type == DioExceptionType.sendTimeout ||e.type ==DioExceptionType.receiveTimeout ||e.type ==DioExceptionType.connectionError ||
                status == 429 ||
                status >= 500;

        if (!retryable ||attempt == 2) {
          rethrow;
        }

        await Future<void>.delayed(
          Duration(
            milliseconds:
                500 * (1 << attempt),
          ),
        );
      }
    }

    throw const CampaignRequestException(
      'Không thể kết nối máy chủ.',
    );
  }

  Future<Map<String, dynamic>> getPost(
    int id,
  ) async {
    try {
      final response = await _retry(
        () => _dio.get(
          'https://jsonplaceholder.typicode.com/posts/$id',
          options: Options(
            sendTimeout:
                const Duration(seconds: 8),
            receiveTimeout:
                const Duration(seconds: 8),
          ),
        ),
      );

      if (response.data is! Map) {
        throw const CampaignRequestException(
          'Dữ liệu chiến dịch không hợp lệ.',
        );
      }

      final data =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      if (data.isEmpty ||
          data['id'] == null) {
        throw CampaignNotFoundException();
      }

      return data;
    } on CampaignNotFoundException {
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode ==
          404) {
        throw CampaignNotFoundException();
      }

      throw const CampaignRequestException(
        'Không tải được nội dung chiến dịch.',
      );
    }
  }

  // khi unsplash lỗi, trả null để k bị crash
  Future<CampaignPhoto?> getPhoto(
    int id,
  ) async {
    final apiKey =
        dotenv.env['UNSPLASH_ACCESS_KEY']
                ?.trim() ??
            '';

    // Kh có ảnh thì campaign vẫn hđ
    if (apiKey.isEmpty) {
      return null;
    }


    final query = switch (id) {
      12 => 'summer travel beach',
      45 => 'technology conference',
      88 => 'loyalty membership',
      99 => 'shopping sale gifts',
      _ => 'marketing campaign',
    };

    try {
      final response = await _retry(
        () => _dio.get(
          'https://api.unsplash.com/search/photos',
          queryParameters: {
            'query': query,
            'page': 1,
            'per_page': 1,
            'orientation': 'landscape',
          },
          options: Options(
            headers: {
              'Authorization':
                  'Client-ID $apiKey',
            },
            sendTimeout:
                const Duration(seconds: 3),
            receiveTimeout:
                const Duration(seconds: 3),
          ),
        ),
      );

      if (response.data is! Map) {
        return null;
      }

      final data =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      final results =
          data['results'] as List? ?? [];

      if (results.isEmpty) {
        return null;
      }

      final photo =
          Map<String, dynamic>.from(
        results.first as Map,
      );

      final urls =
          Map<String, dynamic>.from(
        photo['urls'] as Map? ?? {},
      );

      final user =
          Map<String, dynamic>.from(
        photo['user'] as Map? ?? {},
      );

      final links =
          Map<String, dynamic>.from(
        user['links'] as Map? ?? {},
      );



      final imageUrl =
          urls['regular']?.toString();

      if (imageUrl == null ||
          imageUrl.isEmpty) {
        return null;
      }

      return CampaignPhoto(
        url: imageUrl,
        photographer:
            user['name']?.toString() ??
                'Unsplash',
        photographerUrl:
            links['html']?.toString() ??
                'https://unsplash.com',
      );
    } catch (_) {

      return null;
    }
  }
}