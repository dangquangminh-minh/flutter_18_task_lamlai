import '../../../domain/models/country_model.dart';
import '../../../domain/models/weather_model.dart';

enum WeatherStatus {
  initial,
  loading,
  success,
  failure,
}

class WeatherState {
  const WeatherState({
    this.status =
        WeatherStatus.initial,
    this.country,
    this.weather,
    this.fromCache = false,
    this.message,
  });

  final WeatherStatus status;

  final CountryModel? country;

  final WeatherModel? weather;

  final bool fromCache;

  final String? message;
}