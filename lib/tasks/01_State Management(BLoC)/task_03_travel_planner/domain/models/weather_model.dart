class HourlyWeatherModel {
  const HourlyWeatherModel({
    required this.time,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  final DateTime time;
  final double temperature;
  final String description;
  final String iconCode;

  String get iconUrl=>iconCode.isEmpty
      ? ''
      : 'https://openweathermap.org/img/wn/$iconCode@2x.png';


  factory HourlyWeatherModel.fromJson(Map<String,dynamic> json) {
    return HourlyWeatherModel(
      time:DateTime.tryParse(json['time']?.toString() ?? '') ?? DateTime.now(),
      temperature:(json['temperature'] as num?)?.toDouble() ?? 0,
      description:json['description']?.toString() ?? '',
      iconCode:json['iconCode']?.toString() ?? '',
    );
  }

  Map<String,dynamic> toJson()=>{
    'time':time.toIso8601String(),
    'temperature':temperature,
    'description':description,
    'iconCode':iconCode,
  };
}

class WeatherModel {
  const WeatherModel({
    required this.city,
    required this.countryCode,
    required this.temperature,
    required this.feelsLike,

    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.iconCode,
    
    required this.humidity,
    required this.windSpeedKmh,
    required this.pressure,
    required this.visibilityKm,

    required this.updatedAt,
    required this.hourly,
  });

  final String city;
  final String countryCode;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeedKmh;
  final int pressure;
  final double visibilityKm;

  final DateTime updatedAt;
  final List<HourlyWeatherModel> hourly;

  String get iconUrl=>iconCode.isEmpty
      ? ''
      : 'https://openweathermap.org/img/wn/$iconCode@4x.png';

  factory WeatherModel.fromApi({
    required Map<String,dynamic> current,
    Map<String,dynamic>? forecast,
  }) {
    final main=_map(current['main']);
    final wind=_map(current['wind']);
    final sys=_map(current['sys']);
    final weatherList=_list(current['weather']);
    final weather=weatherList.isNotEmpty ? _map(weatherList.first) : <String,dynamic>{};

    final hourly=<HourlyWeatherModel>[];
    final forecastList=_list(forecast?['list']);

    for(final raw in forecastList.take(8)) {
      if(raw is! Map) continue;

      final item=Map<String,dynamic>.from(raw);
      final itemMain=_map(item['main']);
      final itemWeatherList=_list(item['weather']);
      final itemWeather=itemWeatherList.isNotEmpty
          ? _map(itemWeatherList.first)
          : <String,dynamic>{};

      hourly.add(
        HourlyWeatherModel(
          time:DateTime.fromMillisecondsSinceEpoch(
            ((item['dt'] as num?)?.toInt() ?? 0)*1000,
          ),
          temperature:(itemMain['temp'] as num?)?.toDouble() ?? 0,
          description:itemWeather['description']?.toString() ?? '',
          iconCode:itemWeather['icon']?.toString() ?? '',
        ),
      );
    }

    return WeatherModel(
      city:current['name']?.toString() ?? '',
      countryCode:sys['country']?.toString() ?? '',
      temperature:(main['temp'] as num?)?.toDouble() ?? 0,
      feelsLike:(main['feels_like'] as num?)?.toDouble() ?? 0,
      tempMin:(main['temp_min'] as num?)?.toDouble() ?? 0,
      tempMax:(main['temp_max'] as num?)?.toDouble() ?? 0,
      description:weather['description']?.toString() ?? '',
      iconCode:weather['icon']?.toString() ?? '',
      humidity:(main['humidity'] as num?)?.toInt() ?? 0,
      windSpeedKmh:((wind['speed'] as num?)?.toDouble() ?? 0)*3.6,
      pressure:(main['pressure'] as num?)?.toInt() ?? 0,
      visibilityKm:((current['visibility'] as num?)?.toDouble() ?? 0)/1000,

      updatedAt:DateTime.fromMillisecondsSinceEpoch(
        ((current['dt'] as num?)?.toInt() ?? 0)*1000,
      ),
      hourly:hourly,
    );
  }

  factory WeatherModel.fromJson(Map<String,dynamic> json) {
    final hourlyRaw=_list(json['hourly']);

    return WeatherModel(
      city:json['city']?.toString() ?? '',
      countryCode:json['countryCode']?.toString() ?? '',
      temperature:(json['temperature'] as num?)?.toDouble() ?? 0,
      feelsLike:(json['feelsLike'] as num?)?.toDouble() ?? 0,
      tempMin:(json['tempMin'] as num?)?.toDouble() ?? 0,
      tempMax:(json['tempMax'] as num?)?.toDouble() ?? 0,
      description:json['description']?.toString() ?? '',
      iconCode:json['iconCode']?.toString() ?? '',
      humidity:(json['humidity'] as num?)?.toInt() ?? 0,
      windSpeedKmh:(json['windSpeedKmh'] as num?)?.toDouble() ?? 0,
      pressure:(json['pressure'] as num?)?.toInt() ?? 0,
      visibilityKm:(json['visibilityKm'] as num?)?.toDouble() ?? 0,

      updatedAt:DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      hourly:hourlyRaw
          .whereType<Map>()
          .map((e)=>HourlyWeatherModel.fromJson(Map<String,dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String,dynamic> toJson()=>{
    'city':city,
    'countryCode':countryCode,
    'temperature':temperature,
    'feelsLike':feelsLike,
    'tempMin':tempMin,
    'tempMax':tempMax,
    'description':description,
    'iconCode':iconCode,
    'humidity':humidity,
    'windSpeedKmh':windSpeedKmh,
    'pressure':pressure,
    'visibilityKm':visibilityKm,
    
    'updatedAt':updatedAt.toIso8601String(),
    'hourly':hourly.map((e)=>e.toJson()).toList(),
  };

  static Map<String,dynamic> _map(dynamic value) {
    return value is Map ? Map<String,dynamic>.from(value) : <String,dynamic>{};
  }

  static List<dynamic> _list(dynamic value) {
    return value is List ? value : const [];
  }
}