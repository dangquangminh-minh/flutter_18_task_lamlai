import 'package:equatable/equatable.dart';
import '../models/article_model.dart';


enum NewsStatus {
  initial,
  loading,
  success,
  empty,
  failure,
  loadingMore,
}

class NewsState extends Equatable {
  final NewsStatus status;
  final List<ArticleModel> articles;


  final String query;
  final String topic;
  final String sortBy;

  final int page;
  final int totalResults;
  final bool hasMore;

  final String errorMessage;
  final String loadMoreError;

  const NewsState({
    this.status = NewsStatus.initial,
    this.articles = const [],
    this.query = '',
    this.topic = 'Tất cả',
    this.sortBy = 'publishedAt',
    this.page = 0,
    this.totalResults = 0,
    this.hasMore = false,
    this.errorMessage = '',
    
    this.loadMoreError = '',
  });


  NewsState copyWith({
    NewsStatus? status,
    List<ArticleModel>? articles,
    String? query,
    String? topic,
    String? sortBy,
    int? page,
    int? totalResults,
    bool? hasMore,
    String? errorMessage,

    String? loadMoreError,
  }) {
    return NewsState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      query: query ?? this.query,
      topic: topic ?? this.topic,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      totalResults: totalResults ?? this.totalResults,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,

      loadMoreError: loadMoreError ?? this.loadMoreError,
    );
  }

  @override
  List<Object?> get props => [
    status, articles, query, topic, sortBy, page, totalResults,
    hasMore, errorMessage, loadMoreError,
  ];
}