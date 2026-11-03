

import 'package:flutter/foundation.dart';
import '../../data/repositories/photo_repository.dart';

import '../../domain/models/pixabay_photo.dart';

enum PhotoGalleryStatus { initial, loading, success, error } // trạng thái chính

class PhotoGalleryController extends ChangeNotifier {
  PhotoGalleryController({required this._repository});
  final PhotoRepository _repository;
  PhotoGalleryStatus status = PhotoGalleryStatus.initial;

  List<PixabayPhoto> photos = []; // ds ảnh tải từ api
  String query = 'nature';   // mặc định
  String selectedCategory = 'nature';   // mặc định

  int page = 1;
  int totalHits = 0; // tổng ảnh c.thể truy cập từ t.kiếm

  int transitionVersion = 0;
  bool hasMore = true;
  bool isLoadingMore = false;
  String? errorMessage;

  String? loadMoreError;


  bool _initialized = false; // tránh gọi nh lần
  bool _disposed = false;
  // request id chống race condition
  int _requestId = 0;

  void _notify() { if (!_disposed) notifyListeners(); }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await search(query, category: selectedCategory);
  }

// khi đổi query, chặn request cũ để kq k lẫn giữa các từ khóa
  Future<void> search(String value, {String? category}) async {
    final text = value.trim();
    if (text.isEmpty) return;
    // mỗi y.cầu có 1 id. kq cũ không được ghi đè t.kiếm mới
    final request = ++_requestId;
    query = text;
    selectedCategory = category ?? '';
    page = 1;
    totalHits = 0;
    photos = [];
    hasMore = true;
    isLoadingMore = false;
    errorMessage = null;

    loadMoreError = null;
    status = PhotoGalleryStatus.loading;
    transitionVersion++;
    _notify();
    try {
      final result = await _repository.getPhotos(query: text, page: 1);
      if (_disposed || request != _requestId) return;
      photos = result.photos;
      totalHits = result.totalHits;

      hasMore = photos.length < totalHits && result.photos.length == 20;
      status = PhotoGalleryStatus.success;
    } catch (e) {
      if (_disposed || request != _requestId) return;
      errorMessage = e.toString();
      status = PhotoGalleryStatus.error;
    }
    _notify();
  }

  Future<void> changeCategory(String value) async {
    if (value == selectedCategory) return;
    await search(value, category: value);
  }
  Future<void> refresh() => search(query,
    category: selectedCategory.isEmpty ? null : selectedCategory);

//tải khi còn trang và k có request loadmore đang chạy
  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore || status != PhotoGalleryStatus.success) return;
    final request = _requestId;
    isLoadingMore = true;
    loadMoreError = null;
    _notify();
    try {
      final nextPage = page + 1;
      final result = await _repository.getPhotos(query: query, page: nextPage);
      if (_disposed || request != _requestId) return;


      //loại trùng bằng id
    final seen = photos.map((photo) => photo.id).toSet();
      photos = [...photos, ...result.photos.where((photo) => seen.add(photo.id))];
      page = nextPage;
      totalHits = result.totalHits;
      hasMore = photos.length < totalHits && result.photos.length == 20;     // tải thêm if api còn dl
    } catch (e) {
      if (_disposed || request != _requestId) return;
      loadMoreError = e.toString();
    } finally {
      if (!_disposed && request == _requestId) {
        isLoadingMore = false;
        _notify();
      }
    }
  }

  Future<void> retryLoadMore() => loadMore();
  @override
  void dispose() { _requestId++; _disposed = true; super.dispose(); }
}
