import 'package:dio/dio.dart';

import '../../domain/models/campus_profile.dart';


class ProfileRemoteDataSource {
  ProfileRemoteDataSource({required this._dio});

  final Dio _dio;


  Future<CampusProfile> fetchProfile() async {
    try {
      final response = await _dio.get< Map<String, dynamic>>(
        'https://jsonplaceholder.typicode.com/users/1', options: Options( sendTimeout:
              const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8), validateStatus: (_) => true, ), );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception( 'Profile API trả HTTP ''${response.statusCode}.', );
      }

      return CampusProfile.fromJson( response.data!, );
    } on DioException catch (e) {
      throw Exception( 'Không tải được hồ sơ mẫu: ' '${e.message}', );
    }
  }
}
