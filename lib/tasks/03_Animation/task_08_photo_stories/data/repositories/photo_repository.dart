

import '../../domain/models/pixabay_photo.dart';
import '../datasources/pixabay_remote_data_source.dart';

class PhotoRepository {
  PhotoRepository({
    required PixabayRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PixabayRemoteDataSource _remoteDataSource;

  Future<PixabayPhotoPage> getPhotos({ //lấy ảnh theo từ khóa và trag h.tại vs mỗi trag max 20 ảnh
    required String query,
    required int page,
  }) {
    return _remoteDataSource.getPhotos(
      query: query,
      page: page,
      perPage: 20,
    );
  }
}