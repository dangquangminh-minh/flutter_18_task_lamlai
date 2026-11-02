

import 'weather_sync_settings.dart';


class WeatherSnapshot {
  const WeatherSnapshot({
    required this.cityKey,
    required this.cityName,

    required this.temperature,
    required this.feelsLike, // cảm nhận t.tế
    required this.humidity,
    required this.pressure,
    required this.windKph,

    required this.description,
    required this.weatherMain,
    required this.iconCode,
    required this.syncedAt,
    required this.source,
  });

  final String cityKey;
  final String cityName;

  final double temperature;
  final double feelsLike;

  final int humidity;
  final int pressure;

  final double windKph;

  final String description;
  final String weatherMain;
  final String iconCode;

  final DateTime syncedAt;


  final String source;

  // đọc cấu trúc json openweather
  factory WeatherSnapshot.fromApi({
    required Map<String, dynamic> json,
    required WeatherCity city,
    required String source,
  }) {
    final main = json['main'] as Map<String, dynamic>? ?? {};

    final wind =  json['wind'] as Map<String, dynamic>? ?? {};
    final weatherList =  json['weather'] as List<dynamic>? ?? [];

    final weather = weatherList.isNotEmpty &&
            weatherList.first is Map
        ? Map<String, dynamic>.from(
            weatherList.first as Map,
          )
        : <String, dynamic>{};

    final windMs = (wind['speed'] as num?)?.toDouble() ?? 0;

    return WeatherSnapshot(
      cityKey: city.key,
      cityName:
          json['name']?.toString().trim().isNotEmpty == true
              ? json['name'].toString()
              : city.label,
      temperature:
          (main['temp'] as num?)?.toDouble() ?? 0,
      feelsLike:
          (main['feels_like'] as num?)?.toDouble() ?? 0,
      humidity:
          (main['humidity'] as num?)?.toInt() ?? 0,
      pressure:
          (main['pressure'] as num?)?.toInt() ?? 0,
      windKph: windMs * 3.6,
      description:
          weather['description']?.toString() ??
              'Không rõ',
      weatherMain:
          weather['main']?.toString() ?? '',
      iconCode:
          weather['icon']?.toString() ?? '',
      syncedAt: DateTime.now(),
      source: source,
    );
  }

  // Khôi phục snapshot đã lưu trong Hive, có giá trị mặc định cho dữ liệu thiếu.
  factory WeatherSnapshot.fromMap(
    Map<dynamic, dynamic> map,
  ) {
    return WeatherSnapshot(
      cityKey:
          map['cityKey']?.toString() ?? 'hcm',
      cityName:
          map['cityName']?.toString() ?? '',
      temperature:
          (map['temperature'] as num?)?.toDouble() ??
              0,
      feelsLike:
          (map['feelsLike'] as num?)?.toDouble() ??
              0,
      humidity:
          (map['humidity'] as num?)?.toInt() ?? 0,
      pressure:
          (map['pressure'] as num?)?.toInt() ?? 0,
      windKph:
          (map['windKph'] as num?)?.toDouble() ??
              0,
      description:
          map['description']?.toString() ?? '',
      weatherMain:
          map['weatherMain']?.toString() ?? '',
      iconCode:
          map['iconCode']?.toString() ?? '',
      syncedAt: DateTime.tryParse(
            map['syncedAt']?.toString() ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      source:
          map['source']?.toString() ?? 'cache',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'cityKey': cityKey,
      'cityName': cityName,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'pressure': pressure,
      'windKph': windKph,
      'description': description,

      'weatherMain': weatherMain,
      'iconCode': iconCode,
      'syncedAt': syncedAt.toIso8601String(),
      'source': source,
    };
  }
}