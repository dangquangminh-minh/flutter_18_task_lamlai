
class TodoSuggestion {
  const TodoSuggestion({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,

  });

  final int id;
  final int userId;
  final String title;
  final bool completed;


  factory TodoSuggestion.fromJson(
    Map<String, dynamic> json,
  ) {
    return TodoSuggestion(
      id: (json['id'] as num?)?.toInt() ?? 0,
      
      userId:
          (json['userId'] as num?)?.toInt() ?? 0,

      title: json['title']?.toString() ?? '',
      completed:
          json['completed'] == true,
    );
  }
}