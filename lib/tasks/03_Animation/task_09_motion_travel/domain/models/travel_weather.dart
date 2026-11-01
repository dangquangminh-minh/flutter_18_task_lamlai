

class TravelWeather {
  const TravelWeather({
    required this.temperature,

    required this.feelsLike, // n.độ cảm nhận thực tế
    required this.humidity, // độ ẩm kk

    required this.windKmh,
    required this.description,
    required this.icon,
  });

  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windKmh;
  final String description;

  final String icon;




  factory TravelWeather.fromJson(Map<String, dynamic> json) {
    final main = Map<String, dynamic>.from(json['main'] ?? {});
    final wind = Map<String, dynamic>.from(json['wind'] ?? {});
    final weather = json['weather'] as List? ?? [];

    String description = 'Không rõ'; // m.định
    
    String icon = '';

    if (weather.isNotEmpty) {
      final first = Map<String, dynamic>.from(weather.first);
      description = first['description']?.toString() ?? 'Không rõ';
      icon = first['icon']?.toString() ?? '';
    }

    return TravelWeather(
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windKmh:
          ((wind['speed'] as num?)?.toDouble() ?? 0) * 3.6,
      description: description,
      icon: icon,
    );
  }

  String get iconUrl {
    if (icon.isEmpty) return '';

    return 'https://openweathermap.org/img/wn/$icon@2x.png';
  }
}