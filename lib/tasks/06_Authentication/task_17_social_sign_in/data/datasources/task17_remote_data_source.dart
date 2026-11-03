import 'package:dio/dio.dart';

import '../../domain/models/task17_models.dart';


class Task17RemoteDataSource {
  Task17RemoteDataSource({Dio? dio})
      : _dio=dio ?? Dio( BaseOptions( baseUrl:'https://jsonplaceholder.typicode.com',
            connectTimeout:const Duration(seconds:8), receiveTimeout:const Duration(seconds:8 ),

            sendTimeout:const Duration(seconds:8), ), );

  final Dio _dio;


  Future<Task17Profile> getProfile( int userId, ) async {
    try {
      final response=await _dio.get( '/users/$userId', );

      if(response.statusCode!=200 || response.data is! Map) {
        throw Exception( 'Profile API trả HTTP ${response.statusCode}.', );
      }

      return Task17Profile.fromJson( Map<String,dynamic>.from( response.data as Map, ), );
    } on DioException catch(e) {
      throw Exception( _dioMessage(e), );
    }
  }

  Future<List<Task17Post>> getPosts( int userId, ) async {
    try {
      final response=await _dio.get( '/posts', queryParameters:{
          'userId':userId, }, );

      if(response.statusCode!=200 || response.data is! List) {
        throw Exception( 'Posts API trả HTTP ${response.statusCode}.', );
      }

      return (response.data as List) .whereType<Map>() .map( (e)=>Task17Post.fromJson(
              Map<String,dynamic>.from(e), ), )
          .toList();
    } on DioException catch(e) {
      throw Exception( _dioMessage(e), );
    }
  }

  String _dioMessage(DioException e) {
    switch(e.type) {
      case DioExceptionType.connectionTimeout: case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout: return 'Kết nối API quá thời gian.';

      case DioExceptionType.connectionError: return 'Không có kết nối mạng.';

      default: return 'Không tải được dữ liệu JSONPlaceholder.';
    }
  }
}
