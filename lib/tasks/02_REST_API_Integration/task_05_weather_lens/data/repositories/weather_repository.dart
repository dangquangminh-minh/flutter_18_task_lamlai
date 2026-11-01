import '../../domain/models/weather_models.dart';
import '../datasources/weather_remote_data_source.dart';


class WeatherRepository {
  WeatherRepository({
    required this._remoteDataSource,
  });

  final WeatherRemoteDataSource _remoteDataSource;


  Future<WeatherBundle> searchCity(String city) async {
    final results = await Future.wait([
      _remoteDataSource.getCurrentByCity(city),
      _remoteDataSource.getForecastByCity(city),
    ]);

    return WeatherBundle(
      current: results[0] as CurrentWeather,
      forecast: results[1] as List<ForecastItem>,
    );
  }


  Future<WeatherBundle> searchCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    final results = await Future.wait([
      _remoteDataSource.getCurrentByCoordinates(
        latitude: latitude,
        longitude: longitude,
      ),
      _remoteDataSource.getForecastByCoordinates(
        latitude: latitude,
        longitude: longitude,
      ),
    ]);

    return WeatherBundle(
      current: results[0] as CurrentWeather,
      forecast: results[1] as List<ForecastItem>,
    );
  }
}