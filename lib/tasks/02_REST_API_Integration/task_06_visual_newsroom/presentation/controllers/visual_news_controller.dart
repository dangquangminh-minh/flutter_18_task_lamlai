import 'package:flutter/material.dart';
import '../../data/repositories/visual_news_repository.dart';

import '../../domain/models/visual_article.dart';


enum NewsroomStatus { initial, loading, success, error }


class VisualNewsController extends ChangeNotifier {
  VisualNewsController({required VisualNewsRepository repository})
      : _repository = repository;
  final VisualNewsRepository _repository;

  NewsroomStatus status = NewsroomStatus.initial;
  List<VisualArticle> articles = [];
  String topic = 'technology';
  // page đếm số trang 
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;
  bool isOffline = false;
  bool loadMoreFailed = false;
  String? errorMessage;
  String? lastCacheTime;


  int _requestId = 0;

  final topics = const {
    'technology': 'Công nghệ',
    'science': 'Khoa học',
    'business': 'Kinh doanh',
    'photography': 'Nhiếp ảnh',
    'design': 'Thiết kế' ,
  };

  // tải trang đầu
  Future<void> loadInitial() async {
    final request = ++_requestId;
    status = NewsroomStatus.loading;
    errorMessage = null;
    page = 1;
    hasMore = true;

    loadMoreFailed = false;
    isLoadingMore = false;
    notifyListeners();

    try {

      final cached = await _repository.getCachedNews(topic);
      if (request != _requestId) return;
      if (cached.isNotEmpty) {

        articles = cached;
        status = NewsroomStatus.success;
        isOffline = true; // hiện dl cũ trong lúc đợi mạng
        notifyListeners();
      } else {
        articles = [];
      }
      //api t.công, thay ds cũ bằng dữ liệu mới cùng chủ đề
      final fetched = await _repository.getNews(topic: topic, page: 1);
      if (request != _requestId) return;
      articles = fetched;
      isOffline = _repository.lastUsedCache;
      hasMore = !isOffline && fetched.length == 10;
      lastCacheTime = await _repository.getLastCacheTime(topic);
      status = NewsroomStatus.success;
    } catch (error) {
      if (request != _requestId) return;
      // Chỉ báo trạng thái error khi không còn dữ liệu cũ nào để hiển thị.
      if (articles.isEmpty) {
        errorMessage = error.toString();
        status = NewsroomStatus.error;
      } else {
        isOffline = true;
        status = NewsroomStatus.success;
      }
    }
    notifyListeners();
  }

  // đổi chủ đề phải xóa kq cũ rồi bắt đầu lại từ trang 1
  Future<void> changeTopic(String value) async {
    if (topic == value) return;
    topic = value;
    articles = [];
    await loadInitial();
  }

  // Pull-to-refresh gọi lại luồng tải đầu
  Future<void> refresh() => loadInitial();

  //phân trang khi online, chưa tải và tr.thái đang thành công
  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore || isOffline || status != NewsroomStatus.success) return;
    isLoadingMore = true;
    loadMoreFailed = false;

    final request = _requestId;
    final currentTopic = topic;

    notifyListeners();
    try {
      final fetched = await _repository.getNews(topic: currentTopic, page: page + 1);
      if (request != _requestId) return;

      final ids = articles.map((a) => a.id).toSet();
      articles = [...articles, ...fetched.where((a) => !ids.contains(a.id))];
      page++;
      hasMore = fetched.length == 10;

    } catch (_) {
      if (request != _requestId) return;

      loadMoreFailed = true;

    } finally {
      if (request == _requestId) {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  // ghi bookmark xuống sqlite trc, rồi update lại thẻ đúng id trên ui
  Future<void> toggleBookmark(int index) async {
    if (index < 0 || index >= articles.length) return;
    final article = articles[index];
    final isSaved = await _repository.toggleBookmark(article);
    final currentIndex = articles.indexWhere((item) => item.id == article.id);
    if (currentIndex == -1) return;
    articles[currentIndex] = article.copyWith(isBookmarked: isSaved);
    notifyListeners();
  }
}
