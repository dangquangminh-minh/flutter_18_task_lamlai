
class NewsArticle {
  const NewsArticle({
    required this.articleKey, //khóa bài báo
    required this.sourceName,
    required this.title,

    required this.url,
    required this.publishedAt, // thời điểm xuất bản
    required this.updatedAt,

    this.author,
    this.description,
    this.thumbnailUrl,
    this.thumbnailLocalPath, // đg dẫn đã tải về máy

    this.bookmarked = false, // đánh dấu đã lưu
    this.isRead = false, // đã đọc
  });

  final String articleKey;

  final String sourceName;
  final String? author;

  final String title;
  final String? description;

  final String url;
  final DateTime? publishedAt;

  final String? thumbnailUrl;
  final String? thumbnailLocalPath;

  final bool bookmarked;
  final bool isRead;

  final DateTime updatedAt;


  factory NewsArticle.fromDb(
    Map<String, Object?> map,
  ) {
    return NewsArticle(
      articleKey:
          map['article_key']?.toString() ?? '',
      sourceName:
          map['source_name']?.toString() ?? 'Unknown',
      author:
          map['author']?.toString(),
      title:
          map['title']?.toString() ?? '',
      description:
          map['description']?.toString(),
      url:
          map['url']?.toString() ?? '',
      publishedAt:
          DateTime.tryParse(
        map['published_at']?.toString() ?? '',
      ),
      thumbnailUrl:
          map['thumbnail_url']?.toString(),
      thumbnailLocalPath:
          map['thumbnail_local_path']?.toString(),
      bookmarked:
          (map['bookmarked'] as int? ?? 0) == 1,
      isRead:
          (map['is_read'] as int? ?? 0) == 1,
      updatedAt:
          DateTime.tryParse(
            map['updated_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }


  Map<String, Object?> toDb({
    required String sessionId,
  }) {
    return {
      'article_key': articleKey,
      'source_name': sourceName,
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'published_at':
          publishedAt?.toIso8601String(),
      'thumbnail_url': thumbnailUrl,
      'thumbnail_local_path':
          thumbnailLocalPath,
      'updated_at':
          updatedAt.toIso8601String(),
      'last_sync_session': sessionId,
    };
  }
}