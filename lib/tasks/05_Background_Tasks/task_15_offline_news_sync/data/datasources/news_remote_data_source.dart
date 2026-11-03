
import 'package:dio/dio.dart';


class NewsSyncRemoteException
    implements Exception {
  const NewsSyncRemoteException(
    this.message, {
    required this.retryable,
  });

  final String message;
  final bool retryable;

  @override
  String toString() => message;
}


class RemoteNewsArticle {
  const RemoteNewsArticle({
    required this.sourceName,
    required this.title,
    required this.url,
    this.author,
    this.description,
    this.publishedAt,
  });

  final String sourceName;
  final String? author;

  final String title;
  final String? description;
  final String url;

  final DateTime? publishedAt;
}

// kết quả ảnh từ Pixabay
class PixabayImageAsset {
  const PixabayImageAsset({
    required this.imageUrl,
    required this.pageUrl,
  });

  final String imageUrl;
  final String pageUrl;
}


class NewsRemoteDataSource {
  NewsRemoteDataSource({required this._dio});

  final Dio _dio;

  Future<List<RemoteNewsArticle>>
      //lấy tin từ NewsAPI theo từ khóa
      fetchNews({
    required String apiKey,
    required String query,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const NewsSyncRemoteException(
        'NEWS_API_KEY chưa được cấu hình.',
        retryable: false,
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>( 'https://newsapi.org/v2/everything',
        queryParameters: {
          'q': query,
          'sortBy': 'publishedAt',
          'pageSize': 12,
          'page': 1,
        },
        options: Options(
          headers: {
            'X-Api-Key': apiKey,
          },
          sendTimeout:
              const Duration(seconds: 10),
          receiveTimeout:
              const Duration(seconds: 10),
          validateStatus: (_) => true,
        ),
      );

      final status =
          response.statusCode ?? 0;

      if (status == 401 || status == 403) {
        throw const NewsSyncRemoteException(
          'NewsAPI key không hợp lệ '
          'hoặc không có quyền truy cập.',
          retryable: false,
        );
      }

      if (status == 408 || status == 429 ||  status >= 500) {
        throw NewsSyncRemoteException(
          'NewsAPI tạm thời lỗi '
          '(HTTP $status).',
          retryable: true,
        );
      }

      if (status < 200 || status >= 300 || response.data == null) {
        throw NewsSyncRemoteException(
          'NewsAPI trả HTTP $status.',
          retryable: false,
        );
      }

      final raw =  response.data!['articles'];

      if (raw is! List) {
        return [];
      }

      return raw
          .whereType<Map>()
          .map(
            (item) {
              final map = Map<String, dynamic>.from(
                item,
              );

              final source =  map['source'];

              String sourceName = 'Unknown';

              if (source is Map) {
                sourceName =
                    source['name']
                            ?.toString() ??
                        'Unknown';
              }

              return RemoteNewsArticle(
                sourceName: sourceName,
                author: map['author']
                        ?.toString(),
                title:  map['title']
                        ?.toString() ??
                        'Không có tiêu đề',
                description:  map['description']
                        ?.toString(),
                url:  map['url']
                        ?.toString() ??
                        '',
                publishedAt:
                    DateTime.tryParse(
                  map['publishedAt']
                          ?.toString() ??
                      '',
                ),
              );
            },
          )
          .where(
            (item) =>
                item.url.isNotEmpty &&
                item.title.isNotEmpty,
          ).toList();
    } on NewsSyncRemoteException {
      rethrow;
    } on DioException catch (e) {
      final retryable =
          e.type ==  DioExceptionType.connectionTimeout ||e.type ==  DioExceptionType.receiveTimeout ||  e.type == DioExceptionType.sendTimeout ||e.type ==DioExceptionType.connectionError || e.type == DioExceptionType.unknown;

      throw NewsSyncRemoteException(
        retryable
            ? 'Không kết nối được NewsAPI.'
            : 'NewsAPI: ${e.message}',
        retryable: retryable,
      );
    }
  }

  Future<List<PixabayImageAsset>>
      // lấy danh sách hình từ Pixabay
      fetchPixabayImages({
    required String apiKey,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const NewsSyncRemoteException(
        'PIXABAY_API_KEY chưa được cấu hình.',
        retryable: false,
      );
    }

    try {
      final response =  await _dio.get<Map<String, dynamic>>( 'https://pixabay.com/api/',
        queryParameters: {
          'key': apiKey,
          'q': 'mobile technology',
          'image_type': 'photo',
          'orientation':
              'horizontal',
          'safesearch': true,
          'per_page': 12,
        },
        options: Options(
          sendTimeout:
              const Duration(seconds: 10),
          receiveTimeout:
              const Duration(seconds: 10),
          validateStatus: (_) => true,
        ),
      );

      final status =
          response.statusCode ?? 0;

      if (status == 408 || status == 429 || status >= 500) {
        throw NewsSyncRemoteException(
          'Pixabay tạm thời lỗi '
          '(HTTP $status).',
          retryable: true,
        );
      }

      if (status < 200 ||  status >= 300 ||
          response.data == null) {
        throw NewsSyncRemoteException(
          'Pixabay trả HTTP $status.',
          retryable: false,
        );
      }

      final hits = response.data!['hits'];

      if (hits is! List) {
        return [];
      }

      return hits
          .whereType<Map>()
          .map(
            (raw) {
              final map =
                  Map<String, dynamic>.from(
                raw,
              );

              return PixabayImageAsset(
                imageUrl:
                    map['webformatURL']
                            ?.toString() ??
                        '',
                pageUrl:
                    map['pageURL']
                            ?.toString() ??
                        '',
              );
            },
          )
          .where(
            (item) =>
                item.imageUrl.isNotEmpty,
          )
          .toList();
    } on NewsSyncRemoteException {
      rethrow;
    } on DioException catch (e) {
      throw NewsSyncRemoteException(
        'Không kết nối được Pixabay: '
        '${e.message}',
        retryable: true,
      );
    }
  }
}