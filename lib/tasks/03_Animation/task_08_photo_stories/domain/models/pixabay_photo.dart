

class PixabayPhoto {
  const PixabayPhoto({
    required this.id,
    required this.pageUrl,
    required this.type,
    required this.tags,
    required this.webformatUrl,
    required this.largeImageUrl,
    required this.imageWidth,
    required this.imageHeight,
    required this.views,
    required this.downloads,
    
    required this.likes,
    required this.comments,
    required this.user,
    required this.userImageUrl,
  });

  final int id; //p.bt ảnh và loại bỏ trùng khi phân trag

  final String pageUrl;
  final String type;
  final List<String> tags; //ds từ khóa mô tả ảnh
  final String webformatUrl;
  final String largeImageUrl;
  final int imageWidth;
  final int imageHeight;
  final int views;
  final int downloads;
  
  final int likes;
  final int comments;
  final String user;
  final String userImageUrl;

  


  factory PixabayPhoto.fromJson(Map<String, dynamic> json) {
    final tagsText = json['tags']?.toString() ?? '';

    return PixabayPhoto(
      id: _int(json['id']),
      pageUrl: json['pageURL']?.toString() ?? '',
      type: json['type']?.toString() ?? 'photo',
      tags: tagsText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),

      webformatUrl: json['webformatURL']?.toString() ?? '',
      largeImageUrl: json['largeImageURL']?.toString() ?? '',
      imageWidth: _int(json['imageWidth']),
      imageHeight: _int(json['imageHeight']),
      views: _int(json['views']),
      downloads: _int(json['downloads']),
      likes: _int(json['likes']),


      comments: _int(json['comments']),
      user: json['user']?.toString() ?? 'Pixabay User',
      userImageUrl: json['userImageURL']?.toString() ?? '',
    );
  }

  // chuyển dl động thành số int if api trả null 
  static int _int(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0; // or chuỗi k h.lệ thì dùng 0
  }

  String get imageUrl {
    if (largeImageUrl.isNotEmpty) return largeImageUrl;
    return webformatUrl;
  }

  String get title {
    if (tags.isEmpty) return 'Ảnh Pixabay';

    final text = tags.take(2).join(' • ');
    return text[0].toUpperCase() + text.substring(1);
  }

  double get aspectRatio {
    if (imageWidth <= 0 || imageHeight <= 0) return 0.8;

    final ratio = imageWidth / imageHeight;

    //tránh ảnh quá ngang hoặc quá dài
    return ratio.clamp(0.72, 1.08).toDouble();
  }
}

class PixabayPhotoPage {
  const PixabayPhotoPage({
    required this.total,
    required this.totalHits,

    required this.photos,
  });

  final int total;
  final int totalHits;
  final List<PixabayPhoto> photos;
}