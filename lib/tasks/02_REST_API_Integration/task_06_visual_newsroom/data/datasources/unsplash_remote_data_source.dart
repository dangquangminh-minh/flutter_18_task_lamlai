import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class UnsplashImageResult {
  const UnsplashImageResult({
    required this.imageUrl,
    required this.photographerName,
    required this.photographerUrl,
  });

  final String imageUrl;
  final String photographerName;
  final String photographerUrl;
}

//ảnh phụ,chỉ gọi khi api thiếu hình
class UnsplashRemoteDataSource {
  UnsplashRemoteDataSource({required this._dio});

  final Dio _dio;


  Future<UnsplashImageResult?> searchImage(String query) async {
    final key = dotenv.env['UNSPLASH_ACCESS_KEY'];

    if (key == null || key.trim().isEmpty) {
      throw Exception('Thiếu UNSPLASH_ACCESS_KEY trong .env');
    }

    final response = await _dio.get(
      'https://api.unsplash.com/search/photos',

      queryParameters: {
        'query': query,
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

    final data = Map<String, dynamic>.from(response.data);
    final results = data['results'] as List? ?? [];

    //null để bài báo vẫn hiện đc khi k có ảnh
    if (results.isEmpty) {
      return null;
    }

    final photo = Map<String, dynamic>.from(results.first);
    final urls = Map<String, dynamic>.from(photo['urls'] ?? {});
    final user = Map<String, dynamic>.from(photo['user'] ?? {});

    final links = Map<String, dynamic>.from(
      user['links'] ?? {},
    );


    final imageUrl =
        urls['regular']?.toString() ??
        urls['small']?.toString() ??
        '';

    if (imageUrl.isEmpty) {
      return null;
    }

    // trả tên và liên kết tác giả 
    return UnsplashImageResult(
      imageUrl: imageUrl,
      photographerName:
          user['name']?.toString() ?? 'Unsplash photographer',
      photographerUrl:
          links['html']?.toString() ?? 'https://unsplash.com',
    );
  }
}