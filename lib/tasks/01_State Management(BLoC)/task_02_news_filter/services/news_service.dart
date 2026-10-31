import 'package:dio/dio.dart';
import '../models/article_model.dart';


class NewsPageResult {
  final List<ArticleModel> articles;
  final int totalResults;
  final int receivedCount;

  const NewsPageResult({
    required this.articles,
    required this.totalResults,
    required this.receivedCount,
  });
}

class NewsApiException implements Exception {
  final String message;

  const NewsApiException(this.message);

  @override
  String toString() => message;
}

class NewsService {
  final String apiKey;

  static const int pageSize = 10;

  // cấu hình địa chỉ api và thời gia chờ kết nối
  final Dio _dio = Dio(
    BaseOptions(

      baseUrl: 'https://newsapi.org/v2/',
      connectTimeout: const Duration(seconds: 12),

      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  NewsService({required this.apiKey});


  String _buildQuery(String query, String topic) {
    const keywords = {
      'Công nghệ': 'technology',
      'Kinh doanh': 'business',
      'Thể thao': 'sports',
      'Khoa học': 'science',
    };

    final text = query.trim();
    final topicKeyword = keywords[topic];

    if (topicKeyword == null) {
      return text.isEmpty ? 'flutter' : text;
    }

    if (text.isEmpty) return topicKeyword;

    // tìm bài liên quan đến từ khóa và c.đề
    return '($text) AND $topicKeyword';
  }

  Future<NewsPageResult> fetchNews({
    required String query,
    required String topic,
    required String sortBy,
    required int page,
  }) async {
    if (apiKey.isEmpty) {
      throw const NewsApiException(
        'Chưa tìm thấy NEWS_API_KEY trong file .env.',
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'everything',
        queryParameters: {
          'q': _buildQuery(query, topic),
          'page': page,
          'pageSize': pageSize,
          'sortBy': sortBy,
          'language': 'en',
        },
        options: Options(
          headers: {'X-Api-Key': apiKey},
        ),
      );

      final data = response.data;

      if (data == null || data['status'] != 'ok') {
        throw const NewsApiException('Dữ liệu NewsAPI không hợp lệ.');
      }

      final rawList = data['articles'] as List<dynamic>? ?? [];



      final articles = <ArticleModel>[];

      for (final item in rawList) {
        if (item is! Map) continue;

        final article = ArticleModel.fromJson(
          Map<String, dynamic>.from(item),
        );

        if (article.title == '[Removed]') continue;
        if (!article.url.startsWith('https://') &&
            !article.url.startsWith('http://')) {
          continue;
        }

        articles.add(article);
      }

      return NewsPageResult(
        articles: articles,
        totalResults: (data['totalResults'] as num?)?.toInt() ?? 0,
        receivedCount: rawList.length,
      );
    } on DioException catch (error) {

      // đọc mã lỗi của newsapi
      final body = error.response?.data;
      final code = body is Map ? body['code']?.toString() : null;
      final statusCode = error.response?.statusCode;

      if (code == 'apiKeyInvalid' ||
          code == 'apiKeyMissing' ||
          statusCode == 401) {
        throw const NewsApiException(
          'API key không hợp lệ. Hãy kiểm tra file .env.',
        );
      }

      if (statusCode == 429 ||
          code == 'apiKeyExhausted' ||
          code == 'rateLimited') {
        throw const NewsApiException(
          'Đã vượt giới hạn yêu cầu của NewsAPI.',
        );
      }

      if (statusCode == 426) {
        throw const NewsApiException(
          'Gói NewsAPI hiện tại không hỗ trợ yêu cầu này.',
        );
      }

      if (statusCode != null) {
        throw NewsApiException(
          'Không tải được tin tức (HTTP $statusCode).',
        );
      }

      throw const NewsApiException(
        'Không thể kết nối. Hãy kiểm tra Internet.',
      );
    }
  }
}