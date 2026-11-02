

class PostModel {
  const PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  // đọc num rồi chuyển int để a.toàn nếu trả giá trị số k đúng kiểu int

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
    );
  }
}