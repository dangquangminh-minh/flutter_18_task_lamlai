import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/travel_repository.dart';
import 'weather_event.dart';
import 'weather_state.dart';


class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc(this._repository) : super(const WeatherState()) {
    on<WeatherRequested>(_onRequested);
    on<WeatherRetryRequested>(_onRetry);
  }

  final TravelRepository _repository;
  int _requestVersion = 0;


  Future<void> _onRequested(
    WeatherRequested event,
    Emitter<WeatherState> emit,
  ) async {

    final requestId = ++_requestVersion;
    emit(WeatherState(
      status: WeatherStatus.loading,
      country: event.country,
    ));

    try {
      final result = await _repository.loadWeather(event.country);
      if (isClosed || requestId != _requestVersion) return;

      emit(WeatherState(
        status: WeatherStatus.success,
        country: event.country,
        weather: result.data,
        fromCache: result.fromCache,
      ));
    } catch (error) {
      
      if (isClosed || requestId != _requestVersion) return;
      emit(WeatherState(
        status: WeatherStatus.failure,
        country: event.country,
        message: error.toString(),
      ));
    }
  }

  // dừng lại quốc gia đag xem khi ng dùng bấm thử lại
  void _onRetry(
    WeatherRetryRequested event,
    Emitter<WeatherState> emit,
  ) {
    final country = state.country;
    if (country != null) add(WeatherRequested(country));
  }
}
