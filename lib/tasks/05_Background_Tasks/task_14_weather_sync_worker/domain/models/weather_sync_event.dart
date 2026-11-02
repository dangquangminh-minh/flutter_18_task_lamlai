
class WeatherSyncEvent {
  const WeatherSyncEvent({
    required this.type,
    required this.message,
    required this.createdAt,
    required this.success,
  });

  final String type;
  final String message;
  final DateTime createdAt;
  final bool success;

  // đọc ls sự kiện đã lưu từ hive
  factory WeatherSyncEvent.fromMap(
    Map<dynamic, dynamic> map,
  ) {
    return WeatherSyncEvent(
      type: map['type']?.toString() ?? 'info',
      message:
          map['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(
            map['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
      success: map['success'] == true,
    );
  }

  // chuyển sự kiện thành Map để ghi lịch sử trong hive
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'message': message,
      'createdAt':
          createdAt.toIso8601String(),
      'success': success,
    };
  }
}