
class ReminderSettings {
  const ReminderSettings({
    required this.hour,
    required this.minute,
    required this.repeatDays, // ngày lặp
    required this.enabled,


    this.sound = true,
    this.vibration = true,
  });

  final int hour;
  final int minute;

  
  final Set<int> repeatDays;

  final bool enabled;
  final bool sound;
  final bool vibration;

  // tạo lịch nhắc m.định ở lần mở đầu tiên
  factory ReminderSettings.defaults() {
    return const ReminderSettings(
      hour: 20,
      minute: 30,
      repeatDays: {

        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,

      },
      enabled: false,
    );
  }

  String get timeLabel {
    return '${hour.toString().padLeft(2, '0')}:''${minute.toString().padLeft(2, '0')}';
  }

  String get repeatLabel {
    const names = {
      DateTime.monday: 'T2',
      DateTime.tuesday: 'T3',
      DateTime.wednesday: 'T4',
       DateTime.thursday: 'T5',
      DateTime.friday: 'T6',
      DateTime.saturday: 'T7',
      DateTime.sunday: 'CN',
    };

    final sorted = repeatDays.toList()..sort();

    return sorted
        .map((day) => names[day]!).join(', ');
  }

  // tạo c.hình mới chỉ với trường cần đổi
  ReminderSettings copyWith({
    int? hour,
    int? minute,
    Set<int>? repeatDays,
    bool? enabled,
    bool? sound,
    bool? vibration,
  }) {

    return ReminderSettings(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatDays:
          repeatDays ?? Set<int>.from(this.repeatDays),
      enabled: enabled ?? this.enabled,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
    );
  }
}