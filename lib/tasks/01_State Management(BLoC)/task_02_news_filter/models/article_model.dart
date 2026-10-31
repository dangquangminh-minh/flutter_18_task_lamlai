import 'package:equatable/equatable.dart';

class ArticleModel extends Equatable {
  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final String source;
  final DateTime? publishedAt;

  const ArticleModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.source,
    required this.publishedAt,
  });


  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final sourceData = json['source'];

    return ArticleModel(
      title: json['title']?.toString() ?? 'Không có tiêu đề',
      description: json['description']?.toString() ?? '',
      imageUrl: json['urlToImage']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      source: sourceData is Map
          ? sourceData['name']?.toString() ?? 'Không rõ nguồn'
          : 'Không rõ nguồn',
      publishedAt: DateTime.tryParse(
        json['publishedAt']?.toString() ?? '',
      ),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'urlToImage': imageUrl,
      'url': url,
      'source': {'name': source},
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    title, description, imageUrl, url, source, publishedAt,
  ];
}