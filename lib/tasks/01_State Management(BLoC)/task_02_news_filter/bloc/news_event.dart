import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

// tải lại kq
class NewsRequested extends NewsEvent {
  const NewsRequested();
}


class SearchChanged extends NewsEvent {
  final String query;

  const SearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

// ng.dùng chọn chủ đề khác
class TopicChanged extends NewsEvent {
  final String topic;

  const TopicChanged(this.topic);

  @override
  List<Object?> get props => [topic];
}

// đổi thứ tụ tin mới nhất và phổ biến
class SortChanged extends NewsEvent {
  final String sortBy;

  const SortChanged(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

// cuộn để tải trag tiếp
class LoadMoreNews extends NewsEvent {
  const LoadMoreNews();
}


class RetryLoadMore extends NewsEvent {
  const RetryLoadMore();
}