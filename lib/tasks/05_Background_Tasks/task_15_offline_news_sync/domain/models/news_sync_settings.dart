
class NewsSyncSettings {
  const NewsSyncSettings({
    required this.query, // key lấy tin tức
    required this.intervalMinutes, // chu kì đồng bộ
    required this.wifiOnly,
    required this.notificationsEnabled,
    required this.workerEnabled, // tắt đồng bộ định kì
  });

  final String query;
  final int intervalMinutes;

  final bool wifiOnly;
  final bool notificationsEnabled;
  final bool workerEnabled;


  factory NewsSyncSettings.defaults() {
    return const NewsSyncSettings(
      query: 'mobile',
      intervalMinutes: 15,
      wifiOnly: false,
      notificationsEnabled: true,
      workerEnabled: false,
    );
  }


  NewsSyncSettings copyWith({
    String? query,
    int? intervalMinutes,
    bool? wifiOnly,
    bool? notificationsEnabled,
    bool? workerEnabled,
  }) {
    return NewsSyncSettings(
      query: query ?? this.query,
      intervalMinutes:
          intervalMinutes ?? this.intervalMinutes,
      wifiOnly:
          wifiOnly ?? this.wifiOnly,
      notificationsEnabled:
          notificationsEnabled ??
              this.notificationsEnabled,
      workerEnabled:
          workerEnabled ?? this.workerEnabled,
    );
  }
}