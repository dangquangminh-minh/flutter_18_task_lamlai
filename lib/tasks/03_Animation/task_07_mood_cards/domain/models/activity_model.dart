

class ActivityModel {
  const ActivityModel({
    required this.id,
    required this.activity,
    required this.type,
    required this.participants,
    required this.price,

    required this.availability,
    required this.accessibility,
    required this.duration,

    required this.kidFriendly,
    required this.link,
  });

  final String id;
  final String activity;
  final String type;
  final int participants;
  final double? price;
  final double? availability;
  final String accessibility;
  final String duration;

  final bool kidFriendly;
  final String link;




  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['key']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      activity: json['activity']?.toString() ?? 'Hoạt động ngẫu nhiên',
      type: json['type']?.toString() ?? 'unknown',
      participants: _toInt(json['participants']) ?? 1,
      price: _toDouble(json['price']),

      availability: _toDouble(json['availability']),
      accessibility: json['accessibility']?.toString() ?? 'Không rõ',
      duration: json['duration']?.toString() ?? 'Không rõ',
      
      kidFriendly: json['kidFriendly'] == true,
      link: json['link']?.toString() ?? '',
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String get typeLabel {
    switch (type) {
      case 'education':
        return 'Học tập';
      case 'recreational':
        return 'Giải trí';
      case 'social':
        return 'Xã hội';
      case 'cooking':
        return 'Nấu ăn';
      case 'relaxation':
        return 'Thư giãn';
      case 'busywork':
        return 'Việc nhẹ';
      case 'charity':
        return 'Thiện nguyện';
      default:
        return type.isEmpty ? 'Khác' : type;
    }
  }

  String get participantLabel {
    return participants <= 1 ? '1 người' : '$participants người';
  }

  String get priceLabel {
    if (price == null) return 'Không rõ';
    if (price == 0) return 'Miễn phí';
    if (price! <= 0.3) return 'Chi phí thấp';
    if (price! <= 0.6) return 'Chi phí vừa';
    return 'Chi phí cao';
  }

  String get accessibilityLabel {
    switch (accessibility.toLowerCase()) { // tránh sai chữ hoa vs thg
      case 'few to no challenges':
        return 'Rất dễ tiếp cận';
      case 'minor challenges':
        return 'Dễ tiếp cận';
      case 'some challenges':
        return 'Có một số trở ngại';
      case 'major challenges':
        return 'Khó tiếp cận';
      default:
        return accessibility;
    }
  }

 // h.thị thơi lượng hđ
  String get durationLabel {
    switch (duration.toLowerCase()) {
      case 'minutes':
        return 'Vài phút';
      case 'hours':
        return 'Vài giờ';
      case 'days':
        return 'Vài ngày';
      default:
        return duration;
    }
  }
}