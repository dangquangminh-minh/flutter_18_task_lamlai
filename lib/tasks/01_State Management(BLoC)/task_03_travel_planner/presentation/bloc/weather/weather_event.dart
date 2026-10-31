import '../../../domain/models/country_model.dart';

abstract class WeatherEvent {
  const WeatherEvent();
}

class WeatherRequested
    extends WeatherEvent {
      
  const WeatherRequested(
    this.country,
  );

  final CountryModel country;
}

class WeatherRetryRequested
    extends WeatherEvent {
  const WeatherRetryRequested();
}