import 'package:dio/dio.dart';

import '../../domain/models/country_model.dart';


class CountryApiException implements Exception {
  const CountryApiException(this.message);
  final String message;

  @override
  String toString() => message;
}


class CountryRemoteDataSource {
  CountryRemoteDataSource({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<List<CountryModel>> fetchCountries() async {
    try {
      // gọi 1l để lấy ds
      final response = await _dio.get<dynamic>(
        'https://countries.dev/countries',
        queryParameters: {
          'fields': 'name,capital,region,subregion,population,flags,flag,alpha2Code',
          'sort': 'name',
          'order': 'asc',
        },
      );
      // ktra dl trc khi ép sang list
      final body = response.data;
      if (body is! List) {
        throw const CountryApiException(
          'Máy chủ trả dữ liệu khác danh sách quốc gia.',
        );
      }
      //bỏ qua phần tử k phải Map
      final countries = body.whereType<Map>().map((row) {
        return CountryModel.fromJson(Map<String, dynamic>.from(row));
      }).where((c) => c.commonName.isNotEmpty).toList();
      
      countries.sort((a, b) => a.commonName.compareTo(b.commonName));
      return countries;
    // phân bt lỗi kết nối vs lỗi http
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      if (error.type == DioExceptionType.connectionTimeout ||error.type == DioExceptionType.receiveTimeout ||error.type == DioExceptionType.connectionError) {
       
        throw const CountryApiException('Không kết nối được API quốc gia. Hãy kiểm tra Internet.');
      }
      throw CountryApiException('Không tải được quốc gia (HTTP ${code ?? 'unknown'}).');

    } on CountryApiException {
      rethrow;
    } catch (error) {
      throw CountryApiException('Không đọc được dữ liệu quốc gia: $error');
    }
  }
}
