
class CurrentWeather {
  const CurrentWeather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,

    required this.description,

    required this.icon,
    required this.latitude,
    required this.longitude,
  });

  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final String description;
  final String icon;
  final double latitude;

  final double longitude;


  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final main = Map<String, dynamic>.from(json['main'] ?? {});
    final wind = Map<String, dynamic>.from(json['wind'] ?? {});
    final sys = Map<String, dynamic>.from(json['sys'] ?? {});
    final coord = Map<String, dynamic>.from(json['coord'] ?? {});
    final weatherList = json['weather'] as List? ?? [];


    Map<String, dynamic> weather = {};
    if (weatherList.isNotEmpty) {
      weather = Map<String, dynamic>.from(weatherList.first);
    }

    return CurrentWeather(
      cityName: json['name']?.toString() ?? 'Unknown',
      country: sys['country']?.toString() ?? '',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      pressure: (main['pressure'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      description: weather['description']?.toString() ?? 'Không rõ',
      icon: weather['icon']?.toString() ?? '',
      latitude: (coord['lat'] as num?)?.toDouble() ?? 0,
      longitude: (coord['lon'] as num?)?.toDouble() ?? 0,
    );
  }


  double get windKmH => windSpeed * 3.6; // hiện km/h * 3.6 do trả về m/s


  String get iconUrl =>
      icon.isEmpty ? '' : 'https://openweathermap.org/img/wn/$icon@2x.png';
}

class ForecastItem {
  const ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.humidity,
    required this.rainProbability,
    required this.description,
    required this.icon,
  });

  final DateTime dateTime;
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final int humidity;
  final double rainProbability;
  final String description;
  final String icon;


  factory ForecastItem.fromJson(
    Map<String, dynamic> json, {
    required int timezoneOffset,
  }) {
    final main = Map<String, dynamic>.from(json['main'] ?? {});
    final weatherList = json['weather'] as List? ?? [];

    Map<String, dynamic> weather = {};
    if (weatherList.isNotEmpty) {
      weather = Map<String, dynamic>.from(weatherList.first);
    }

    // dt là unix timestamp theo s, *1000 để tạo datetime từ m/s
    final timestamp = (json['dt'] as num?)?.toInt() ?? 0;
    final utc = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
      isUtc: true,
    );

    // + utc  để h.thị giờ của t.phố thay vì giờ đ.thoại
    // dateTime ở đây được dùng như giờ địa phương quy ước; không gọi toLocal() nữa.
    final localTime = utc.add(Duration(seconds: timezoneOffset));

    return ForecastItem(
      dateTime: localTime,
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      minTemperature: (main['temp_min'] as num?)?.toDouble() ?? 0,
      maxTemperature: (main['temp_max'] as num?)?.toDouble() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      rainProbability: (json['pop'] as num?)?.toDouble() ?? 0,
      description: weather['description']?.toString() ?? 'Không rõ',
      icon: weather['icon']?.toString() ?? '',
    );
  }

  String get iconUrl =>
      icon.isEmpty ? '' : 'https://openweathermap.org/img/wn/$icon@2x.png';
}

// gộp current và forecast chug
class WeatherBundle {
  const WeatherBundle({
    required this.current,
    required this.forecast,
  });

  final CurrentWeather current;
  final List<ForecastItem> forecast;
}