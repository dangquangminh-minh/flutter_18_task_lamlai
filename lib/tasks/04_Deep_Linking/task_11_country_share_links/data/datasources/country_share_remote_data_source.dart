

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/models/country_share_model.dart';

class CountryShareNotFoundException implements Exception {}

class CountryShareRequestException implements Exception {
  CountryShareRequestException(this.message);

  final String message;

  @override
  String toString()=>message;
}

class CountryShareRemoteDataSource {
  CountryShareRemoteDataSource({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  static const String _baseUrl='https://api.restcountries.com/countries/v5';

  static const String _fields=
      'names.common,names.official,'
      'codes.alpha_2,codes.alpha_3,'
      'capitals,flag.url_png,flag.url_svg,flag.emoji,'
      'region,subregion,population,area,'
      'currencies,languages,timezones,'
      'calling_codes,tlds,coordinates';

  String get _apiKey=>dotenv.env['RESTCOUNTRIES_API_KEY']?.trim() ?? '';


  Options _options() {
    if(_apiKey.isEmpty) {
      throw CountryShareRequestException(
        'Chưa cấu hình RESTCOUNTRIES_API_KEY.',
      );
    }

    return Options(
      headers:{
        'Authorization':'Bearer $_apiKey',
        'Accept':'application/json',
      },
      sendTimeout:const Duration(seconds:15),
      receiveTimeout:const Duration(seconds:15),
    );
  }

  // phân trang limit vs offset
  Future<List<CountryShareModel>> getCountries({String? region}) async {
    try {
      final result=<CountryShareModel>[];
      int offset=0;
      const limit=100;

      while(true) {
        //mỗi vòng lặp cập nhật offset
        final params=<String,dynamic>{
          'limit':limit,
          'offset':offset,
          'response_fields':_fields,
        };

        if(region!=null && region.trim().isNotEmpty) {
          params['region']=region;
        }

        final response=await _dio.get(
          _baseUrl,
          queryParameters:params,
          options:_options(),
        );

        final root=_map(response.data);
        final errors=root['errors'];

        if(errors is List && errors.isNotEmpty) {
          throw CountryShareRequestException(errors.first.toString());
        }

        final data=_map(root['data']);
        final objects=data['objects'] as List? ?? [];

        for(final item in objects) {
          if(item is! Map) continue;

          result.add(
            CountryShareModel.fromJson(
              Map<String,dynamic>.from(item),
            ),
          );
        }

        final meta=_map(data['meta']);
        final more=meta['more']==true;

        // dừng khi api báo hết dl tránh lặp request

        if(!more || objects.isEmpty) break;

        offset+=objects.length;
      }

      result.sort((a,b)=>a.name.compareTo(b.name));

      return result;
    } on CountryShareRequestException {
      rethrow;
    } on DioException catch(e) {
      _throwDioError(
        e,
        fallback:'Không thể tải danh sách quốc gia.',
      );
    }
  }

  // link c.tiết dùng alpha_3  lấy đúng 1 qg
  Future<CountryShareModel> getCountryByCode(String code) async {
    final normalized=code.trim().toUpperCase();

    if(normalized.isEmpty) {
      throw CountryShareNotFoundException();
    }

    try {
      final response=await _dio.get(
        '$_baseUrl/codes.alpha_3/$normalized',
        queryParameters:{'response_fields':_fields},
        options:_options(),
      );

      return _parseSingle(response.data);
    } on CountryShareNotFoundException {
      rethrow;
    } on DioException catch(e) {
      if(e.response?.statusCode==404) {
        throw CountryShareNotFoundException();
      }

      _throwDioError(
        e,
        fallback:'Không thể tải thông tin quốc gia.',
      );
    }
  }

  Future<CountryShareModel> getCountryByName(String name) async {
    final value=name.trim();

    if(value.isEmpty) {
      throw CountryShareNotFoundException();
    }

    try {
      final response=await _dio.get(
        _baseUrl,
        queryParameters:{
          'q':value,
          'limit':20,
          'response_fields':_fields,
        },
        options:_options(),
      );

      final root=_map(response.data);
      final data=_map(root['data']);
      final objects=data['objects'] as List? ?? [];

      if(objects.isEmpty) {
        throw CountryShareNotFoundException();
      }

      CountryShareModel? fallback;

      for(final item in objects) {
        if(item is! Map) continue;

        final country=CountryShareModel.fromJson(
          Map<String,dynamic>.from(item),
        );

        fallback ??=country;

        if(country.name.toLowerCase()==value.toLowerCase() ||
            country.officialName.toLowerCase()==value.toLowerCase()) {
          return country;
        }
      }

      if(fallback!=null) return fallback;

      throw CountryShareNotFoundException();
    } on CountryShareNotFoundException {
      rethrow;
    } on DioException catch(e) {
      if(e.response?.statusCode==404) {
        throw CountryShareNotFoundException();
      }

      _throwDioError(
        e,
        fallback:'Không thể tải thông tin quốc gia.',
      );
    }
  }



  CountryShareModel _parseSingle(dynamic responseData) {
    final root=_map(responseData);
    final data=_map(root['data']);
    final objects=data['objects'] as List? ?? [];

    if(objects.isEmpty || objects.first is! Map) {
      throw CountryShareNotFoundException();
    }

    return CountryShareModel.fromJson(
      Map<String,dynamic>.from(objects.first as Map),
    );
  }

  // 401/403 báo riêng để bt đag thiếu hoặc sai api  key
  Never _throwDioError(
    DioException e,{
    required String fallback,
  }) {
    if(e.response?.statusCode==401 || e.response?.statusCode==403) {
      throw CountryShareRequestException(
        'API key REST Countries không hợp lệ hoặc không có quyền truy cập.',
      );
    }

    throw CountryShareRequestException(
      '$fallback Vui lòng kiểm tra kết nối mạng.',
    );
  }

  Map<String,dynamic> _map(dynamic value) {
    return value is Map
        ? Map<String,dynamic>.from(value)
        : <String,dynamic>{};
  }
}