
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';


class ThumbnailFileStore {
  ThumbnailFileStore({required Dio dio}) : _dio = dio;

  final Dio _dio;

  // tải ảnh bằng Dio, lưu file và trả về local path
  Future<String?> cacheImage(
    String imageUrl,
  ) async {
    if (imageUrl.isEmpty) {
      return null;
    }

    try {
      final root = await getApplicationSupportDirectory();

      final folder = Directory(
        join(
          root.path,
          'task15_news_thumbnails',
        ),
      );

      if (!await folder.exists()) {
        await folder.create(
          recursive: true,
        );
      }

      final fileName = '${sha256.convert(
            imageUrl.codeUnits,
          )}.jpg';

      final file = File(
        join( folder.path, fileName,
        ),
      );

      if (await file.exists()) {
        return file.path;
      }

      final response = await _dio.get<List<int>>(
        imageUrl,
        options: Options(
          responseType:
              ResponseType.bytes,
          receiveTimeout:
              const Duration(seconds: 10),
        ),
      );

      final bytes =  response.data;

      if (bytes == null || bytes.isEmpty) {
        return null;
      }

      await file.writeAsBytes(
        bytes,
        flush: true,
      );

      return file.path;
    } catch (_) {
      return null;
    }
  }
}