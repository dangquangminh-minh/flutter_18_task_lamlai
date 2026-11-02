// CampaignContent gộp post và ảnh; cachedAt/fromCache/stale giúp UI nói rõ nguồn dữ liệu.

class CampaignContent {
  const CampaignContent({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.cachedAt, // ktra dl cũ hay chưa
    this.imageUrl,
    this.photographer,
    this.photographerUrl,


    this.fromCache = false,
    this.stale = false, //dl quá time cache cho phép
  });

  final int id;
  final int userId;

  final String title;
  final String body;

  final String? imageUrl;
  final String? photographer;
  final String? photographerUrl;

  final DateTime cachedAt;

  final bool fromCache;
  final bool stale;



  CampaignContent copyWith({
    bool? fromCache,
    bool? stale,
  }) {
    return CampaignContent(
      id: id,
      userId: userId,
      title: title,
      body: body,
      cachedAt: cachedAt,
      imageUrl: imageUrl,
      photographer: photographer,
      photographerUrl: photographerUrl,
      fromCache: fromCache ?? this.fromCache,
      stale: stale ?? this.stale,
    );
  }



  factory CampaignContent.fromPost(
    Map<String, dynamic> post, {
    required DateTime cachedAt,
    String? imageUrl,
    String? photographer,
    String? photographerUrl,
  }) {
    return CampaignContent(
      id: (post['id'] as num?)?.toInt() ?? 0,
      userId:
          (post['userId'] as num?)?.toInt() ?? 0,
      title:
          post['title']?.toString() ?? '',
      body:
          post['body']?.toString() ?? '',
      cachedAt: cachedAt,
      imageUrl: imageUrl,
      photographer: photographer,
      photographerUrl: photographerUrl,
    );
  }

  factory CampaignContent.fromMap(
    Map<dynamic, dynamic> map,
  ) {
    return CampaignContent(
      id: (map['id'] as num?)?.toInt() ?? 0,
      userId:
          (map['userId'] as num?)?.toInt() ?? 0,
      title:
          map['title']?.toString() ?? '',
      body:
          map['body']?.toString() ?? '',
      imageUrl:
          map['imageUrl']?.toString(),
      photographer:
          map['photographer']?.toString(),
      photographerUrl:
          map['photographerUrl']?.toString(),
      cachedAt: DateTime.tryParse(
            map['cachedAt']?.toString() ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  // chuyển thành map để lưu hive và khôi phục sau khi app tắt

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'photographer': photographer,
      'photographerUrl': photographerUrl,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }
}