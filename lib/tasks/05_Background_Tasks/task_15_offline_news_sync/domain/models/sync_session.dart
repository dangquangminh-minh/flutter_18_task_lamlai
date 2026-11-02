
class SyncSession {
  const SyncSession({
    required this.sessionId, // id rieeg của lần đồng bộ 
    required this.triggerType,
    required this.status,
    required this.startedAt,
    required this.articleCount,
    required this.newCount,
    required this.imageCount,
    required this.duplicateCount,
    required this.queueProcessed,
    this.completedAt,
    this.errorMessage,
  });

  final String sessionId;
  final String triggerType;
  final String status;

  final DateTime startedAt;
  final DateTime? completedAt;

  final int articleCount;
  final int newCount;
  final int imageCount;
  final int duplicateCount;
  final int queueProcessed;

  final String? errorMessage;

  // chuyển sync_sessions từ SQLite thành object dùng trên tab dashboard
  factory SyncSession.fromDb(
    Map<String, Object?> map,
  ) {
    return SyncSession(
      sessionId:
          map['session_id']?.toString() ?? '',
      triggerType:
          map['trigger_type']?.toString() ?? '',
      status:
          map['status']?.toString() ?? '',
      startedAt:
          DateTime.tryParse(
            map['started_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
      completedAt:
          DateTime.tryParse(
        map['completed_at']?.toString() ?? '',
      ),
      articleCount:
          (map['article_count'] as num?)
                  ?.toInt() ??
              0,
      newCount:
          (map['new_count'] as num?)
                  ?.toInt() ??
              0,
      imageCount:
          (map['image_count'] as num?)
                  ?.toInt() ??
              0,
      duplicateCount:
          (map['duplicate_count'] as num?)
                  ?.toInt() ??
              0,
      queueProcessed:
          (map['queue_processed'] as num?)
                  ?.toInt() ??
              0,
      errorMessage:
          map['error_message']?.toString(),
    );
  }
}