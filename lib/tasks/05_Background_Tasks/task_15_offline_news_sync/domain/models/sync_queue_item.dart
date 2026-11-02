
class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.idempotencyKey, // giúp nhận diện thao tác gửi bị trùg
    required this.action,
    required this.articleKey,
    required this.payloadJson, // dl cần xl
    required this.status,
    required this.attemptCount, // số lần thử x.lý
    required this.createdAt,
    required this.updatedAt,
    this.nextRetryAt,
    this.lastError,
  });

  final int id;

  final String idempotencyKey;
  final String action;
  final String articleKey;
  final String payloadJson;

  final String status;

  final int attemptCount;
  final DateTime? nextRetryAt;
  final String? lastError;

  final DateTime createdAt;
  final DateTime updatedAt;



  bool get pending => status == 'pending' || status == 'retry';
  bool get failed => status == 'failed';


  factory SyncQueueItem.fromDb(
    Map<String, Object?> map,
  ) {
    return SyncQueueItem(
      id:
          (map['id'] as num?)?.toInt() ?? 0,
      idempotencyKey:
          map['idempotency_key']?.toString() ?? '',
      action:
          map['action']?.toString() ?? '',
      articleKey:
          map['article_key']?.toString() ?? '',
      payloadJson:
          map['payload_json']?.toString() ?? '{}',
      status:
          map['status']?.toString() ?? 'pending',
      attemptCount:
          (map['attempt_count'] as num?)
                  ?.toInt() ??
              0,
      nextRetryAt:
          DateTime.tryParse(
        map['next_retry_at']?.toString() ?? '',
      ),
      lastError:
          map['last_error']?.toString(),
      createdAt:
          DateTime.tryParse(
            map['created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(
            map['updated_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}