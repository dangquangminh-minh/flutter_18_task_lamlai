
class VisualArticle {
  const VisualArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.topic,
    required this.isBookmarked,
    required this.cachedAt,
    this.imageAuthor,
    this.imageAuthorUrl,
  });

  // id giúp tránh trùng bài 
  final String id;
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String source;
  final String publishedAt;
  final String topic;
  final bool isBookmarked;
  final String? cachedAt;

  final String? imageAuthor;
  final String? imageAuthorUrl;


  factory VisualArticle.fromNewsApi(
    Map<String, dynamic> json, {
    required String topic,
  }) {
    final sourceData = Map<String, dynamic>.from(json['source'] ?? {});

    final url = json['url']?.toString() ?? '';
    final title = json['title']?.toString() ?? 'Không có tiêu đề';

    return VisualArticle(
      id: url.isNotEmpty ? url : '$title-${json['publishedAt']}',
      title: title,
      description: json['description']?.toString() ?? '',
      url: url,

      imageUrl: json['urlToImage']?.toString() ?? '',
      source: sourceData['name']?.toString() ?? 'Unknown',
      publishedAt: json['publishedAt']?.toString() ?? '',
      topic: topic,

       isBookmarked: false,
      cachedAt: null,
    );
  }

  factory VisualArticle.fromMap(Map<String, dynamic> map) {
    return VisualArticle(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      url: map['url'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      source: map['source'] as String? ?? '',
      publishedAt: map['published_at'] as String? ?? '',
      topic: map['topic'] as String? ?? 'technology',

      isBookmarked: (map['is_bookmarked'] as int? ?? 0) == 1,


      cachedAt: map['cached_at'] as String?,
      imageAuthor: map['image_author'] as String?,
      imageAuthorUrl: map['image_author_url'] as String?,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'image_url': imageUrl,
      'source': source,
      'published_at': publishedAt,
      'topic': topic,
      'is_bookmarked': isBookmarked ? 1 : 0,
      'cached_at': cachedAt,

      'image_author': imageAuthor,
      'image_author_url': imageAuthorUrl,
    };
  }


  VisualArticle copyWith({
    String? imageUrl,
    bool? isBookmarked,
    String? cachedAt,
    String? imageAuthor,
    String? imageAuthorUrl,
  }) {
    return VisualArticle(
      id: id,
      title: title,
      description: description,
      url: url,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source,
      publishedAt: publishedAt,
      topic: topic,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      cachedAt: cachedAt ?? this.cachedAt,
      
      imageAuthor: imageAuthor ?? this.imageAuthor,
      imageAuthorUrl: imageAuthorUrl ?? this.imageAuthorUrl,
    );
  }
}