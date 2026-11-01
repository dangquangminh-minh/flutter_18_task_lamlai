

import 'package:dio/dio.dart';

import '../../domain/models/activity_model.dart';

class ActivityRemoteDataSource {
  ActivityRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  //gửi y.cầu lấy 1 hđ ngẫu nhiên
  Future<ActivityModel> getRandomActivity() async {
    try {
      final response = await _dio.get(

        'https://bored-api.appbrewery.com/random',

        options: Options(
          sendTimeout: const Duration(seconds: 10),  // giới hạn time gửi và nhận dl tránh để màn hình load quá lâu khi mạng yếu
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.data is! Map) {
        throw ActivityException('Dữ liệu API không đúng định dạng.');
      }

      return ActivityModel.fromJson(  // nếu t.công thì trả về 1 activitymodel
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||e.type == DioExceptionType.receiveTimeout ||e.type == DioExceptionType.sendTimeout) {
       
        throw ActivityException('Kết nối API quá thời gian.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw ActivityException('Không có kết nối Internet.');
      }


      throw ActivityException(
        'Không thể tải hoạt động. Vui lòng thử lại.',
      );
    }
  }
}

class ActivityException implements Exception {
  const ActivityException(this.message);

  final String message;

  @override
  String toString() => message;
}