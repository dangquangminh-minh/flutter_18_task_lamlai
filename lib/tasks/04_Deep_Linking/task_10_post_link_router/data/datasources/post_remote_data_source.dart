

import 'package:dio/dio.dart';

import '../../domain/models/post_model.dart';

class PostNotFoundException implements Exception {}

class PostRequestException implements Exception {
  PostRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PostRemoteDataSource {
  PostRemoteDataSource({
    required this._dio,
  });

  final Dio _dio;


  Future<PostModel> getPost(int id) async {
    try {
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/posts/$id',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      // ktra dạng dl trc khi prase

      if (response.data is! Map) {
        throw PostRequestException(
          'Dữ liệu bài viết không hợp lệ.',
        );
      }

      final data = Map<String, dynamic>.from(
        response.data,
      );

      // jsonplaceholder c.thể trả object rỗng 

      if (data.isEmpty || data['id'] == null) {
        throw PostNotFoundException();
      }

      return PostModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw PostNotFoundException();
      }

      if (e.type == DioExceptionType.connectionTimeout ||e.type == DioExceptionType.receiveTimeout ||e.type == DioExceptionType.sendTimeout) {
        throw PostRequestException(
          'Kết nối quá chậm. Vui lòng thử lại.',
        );
      }

      throw PostRequestException(
        'Không thể tải bài viết. Kiểm tra kết nối mạng.',
      );
    }
  }

  //tải song song bài k chờ lần lượt từng request
  Future<List<PostModel>> getPosts(
    List<int> ids,
  ) async {
    return Future.wait(
      ids.map(getPost),
    );
  }
}