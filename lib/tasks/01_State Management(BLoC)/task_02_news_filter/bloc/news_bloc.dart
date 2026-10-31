import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../models/article_model.dart';
import '../services/news_service.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends HydratedBloc<NewsEvent, NewsState> {
  final NewsService _service;

  Timer? _searchTimer;

  // mỗi lần tìm kiếm mã request sẽ tăng để api cũ k ghi đè lên cái mới
  int _requestVersion = 0;


  bool _loadingMore = false;

  NewsBloc(this._service) : super(const NewsState()) {
    on<NewsRequested>(_onRequested);
    on<SearchChanged>(_onSearchChanged);
    on<TopicChanged>(_onTopicChanged);

    on<SortChanged>(_onSortChanged);
    on<LoadMoreNews>(_onLoadMore);

    on<RetryLoadMore>(_onRetryLoadMore);
  }


  @override
  String get storagePrefix => 'flutter_task02_news_v1';

  // khi người dùng nhập,không gọi api liền
  //if gõ tiêp trong 500ms thì hủy timer cũ
  void _onSearchChanged(
    SearchChanged event,
    Emitter<NewsState> emit,
  ) {
    if (event.query == state.query) return;

    _searchTimer?.cancel();
    _requestVersion++;

    emit(state.copyWith(
      query: event.query,
      status: NewsStatus.loading,
      articles: [],
      page: 0,
      totalResults: 0,
      hasMore: false,
      errorMessage: '',
      loadMoreError: '',
    ));

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (!isClosed) {
        add(const NewsRequested());
      }
    });
  }

  // chọn chủ đề mới thì hủy debounce và tìm từ trang 1
  Future<void> _onTopicChanged(
    TopicChanged event,
    Emitter<NewsState> emit,
  ) async {
    if (event.topic == state.topic) return;

    _searchTimer?.cancel();

    await _loadFirstPage(
      emit,
      state.copyWith(topic: event.topic),
    );
  }

  // đổi sx thì cx tải lại trg
  Future<void> _onSortChanged(
    SortChanged event,
    Emitter<NewsState> emit,
  ) async {
    if (event.sortBy == state.sortBy) return;

    _searchTimer?.cancel();

    await _loadFirstPage(
      emit,
      state.copyWith(sortBy: event.sortBy),
    );
  }

  Future<void> _onRequested(
    NewsRequested event,
    Emitter<NewsState> emit,
  ) async {
    _searchTimer?.cancel();
    await _loadFirstPage(emit, state);
  }

  // tìm kiếm/lọc/sx/retry
  Future<void> _loadFirstPage(
    Emitter<NewsState> emit,
    NewsState filters,
  ) async {
    final currentRequest = ++_requestVersion;


    emit(filters.copyWith(
      status: NewsStatus.loading,
      articles: [],
      page: 0,
      totalResults: 0,
      hasMore: false,

      errorMessage: '',
      loadMoreError: '',
    ));

    try {
      final result = await _service.fetchNews(
        query: filters.query,
        topic: filters.topic,
        sortBy: filters.sortBy,
        page: 1,
      );

      // có lần tìm mới thì k sd kq cũ
      if (isClosed || currentRequest != _requestVersion) return;

      final hasMore = result.receivedCount == NewsService.pageSize &&
          result.totalResults > NewsService.pageSize;

      emit(state.copyWith(
        status: result.articles.isEmpty
            ? NewsStatus.empty
            : NewsStatus.success,
        articles: result.articles,
        page: 1,
        totalResults: result.totalResults,
        hasMore: hasMore,
      ));
    } catch (error) {
      if (isClosed || currentRequest != _requestVersion) return;

      debugPrint('Task 02 - lỗi tải trang đầu: $error');

      emit(state.copyWith(
        status: NewsStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreNews event,
    Emitter<NewsState> emit,
  ) async {
    await _loadNextPage(emit);
  }

  Future<void> _onRetryLoadMore(
    RetryLoadMore event,
    Emitter<NewsState> emit,
  ) async {
    await _loadNextPage(emit, retry: true);
  }

  Future<void> _loadNextPage(
    Emitter<NewsState> emit, {
    bool retry = false,
  }) async {
    if (_loadingMore ||
        state.status != NewsStatus.success ||
        !state.hasMore) {
      return;
    }

    // đợi ng.dùng bấm retry khi tải lỗi
    if (!retry && state.loadMoreError.isNotEmpty) return;

    _loadingMore = true;
    final currentRequest = _requestVersion;
    final nextPage = state.page + 1;

    emit(state.copyWith(
      status: NewsStatus.loadingMore,
      loadMoreError: '',
    ));

    try {
      final result = await _service.fetchNews(
        query: state.query,
        topic: state.topic,
        sortBy: state.sortBy,
        page: nextPage,
      );

      if (isClosed || currentRequest != _requestVersion) return;

      // dùng url để tránh trùng bài báo
      final usedUrls = state.articles.map((a) => a.url).toSet();

      final newArticles = result.articles.where((article) {
        return usedUrls.add(article.url);
      }).toList();


      final allArticles = [...state.articles, ...newArticles];

      final hasMore = result.receivedCount == NewsService.pageSize &&
          nextPage * NewsService.pageSize < result.totalResults;

      emit(state.copyWith(
        status: NewsStatus.success,
        articles: allArticles,
        page: nextPage,
        totalResults: result.totalResults,
        hasMore: hasMore,
      ));
    } catch (error) {
      if (isClosed || currentRequest != _requestVersion) return;


      emit(state.copyWith(
        status: NewsStatus.success,
        loadMoreError: error.toString(),
      ));
    } finally {
      _loadingMore = false;
    }
  }


  @override
  NewsState? fromJson(Map<String, dynamic> json) {
    try {
      final raw = json['articles'] as List<dynamic>? ?? [];

      final articles = raw.map((item) {
        return ArticleModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();

      final page = (json['page'] as num?)?.toInt() ?? 0;

      return NewsState(
        status: page == 0
            ? NewsStatus.initial
            : articles.isEmpty
                ? NewsStatus.empty
                : NewsStatus.success,
        articles: articles,
        query: json['query']?.toString() ?? '',
        topic: json['topic']?.toString() ?? 'Tất cả',
        sortBy: json['sortBy']?.toString() ?? 'publishedAt',
        page: page,
        totalResults: (json['totalResults'] as num?)?.toInt() ?? 0,
        hasMore: json['hasMore'] == true,
      );
    } catch (error) {
      debugPrint('Task 02 - lỗi đọc cache: $error');
      return null;
    }
  }

  // chỉ lưu dl khi tải t.công và kq rỗng
  @override
  Map<String, dynamic>? toJson(NewsState state) {
    if (state.status != NewsStatus.success &&
        state.status != NewsStatus.empty) {
      return null;
    }


    if (state.loadMoreError.isNotEmpty) return null;

    return {
      'query': state.query,
      'topic': state.topic,
      'sortBy': state.sortBy,
      'page': state.page,
      'totalResults': state.totalResults,

      'hasMore': state.hasMore,
      'articles': state.articles.map((a) => a.toJson()).toList(),
    };
  }

  @override
  Future<void> close() async {
    _searchTimer?.cancel();
    await super.close();
  }
}