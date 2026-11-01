import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/models/visual_article.dart';


class NewsRemoteDataSource {
  NewsRemoteDataSource({required this._dio});

  final Dio _dio;

  // mỗi request lấy max 10 bài
  Future<List<VisualArticle>> fetchNews({
    required String topic,
    required int page,
  }) async {
    //đọc key từ .env 
    final key = dotenv.env['NEWS_API_KEY'];

    if (key == null || key.isEmpty) {
      throw Exception('Thiếu NEWS_API_KEY trong .env');
    }

    final response = await _dio.get(
      'https://newsapi.org/v2/everything',
      queryParameters: {
        'q': topic,
        'page': page,
        'pageSize': 10,

        'sortBy': 'publishedAt',
        'apiKey': key,
      },
    );

    final data = Map<String, dynamic>.from(response.data);

    //ktra trước khi lấy articles
    if (data['status'] != 'ok') {
      throw Exception(data['message'] ?? 'NewsAPI trả về lỗi.');
    }


    final articles = data['articles'] as List? ?? [];

    return articles
        .map((item) => VisualArticle.fromNewsApi(
              Map<String, dynamic>.from(item),
              topic: topic,
            ))
        .toList();
  }
}