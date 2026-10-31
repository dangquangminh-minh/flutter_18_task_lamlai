import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/travel_repository.dart';
import 'country_event.dart';
import 'country_state.dart';

// tải và tìm kiếm qg
class CountryBloc extends Bloc<CountryEvent, CountryState> {
  CountryBloc(this._repository) : super(const CountryState()) {
    on<CountryStarted>(_onStarted);
    on<CountrySearchRequested>(_onSearch);

    on<CountryRetryRequested>(_onRetry);
  }

  final TravelRepository _repository;

  int _requestVersion = 0;

  Future<void> _onStarted(
    CountryStarted event,
    Emitter<CountryState> emit,
  ) async {
    final requestId = ++_requestVersion;
    emit(const CountryState(status: CountryStatus.loading));

    try {
      final result = await _repository.loadFeatured();
      if (isClosed || requestId != _requestVersion) return;

      emit(CountryState(
        status: result.data.isEmpty
            ? CountryStatus.empty
            : CountryStatus.success,
        countries: result.data,
        fromCache: result.fromCache,
      ));
    } catch (error) {
      if (isClosed || requestId != _requestVersion) return;
      emit(CountryState(
        status: CountryStatus.failure,
        message: error.toString(),
      ));
    }
  }
  // tìm kiếm
  Future<void> _onSearch(
    CountrySearchRequested event,
    Emitter<CountryState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      add(const CountryStarted());
      return;
    }

    final requestId = ++_requestVersion;
    emit(CountryState(
      status: CountryStatus.loading,
      
      countries: state.countries,
      query: query,
    ));

    try {
      final result = await _repository.searchCountries(query);
      if (isClosed || requestId != _requestVersion) return;

      emit(CountryState(
        status: result.data.isEmpty
            ? CountryStatus.empty
            : CountryStatus.success,
        countries: result.data,
        fromCache: result.fromCache,
        query: query,
      ));
    } catch (error) {
      if (isClosed || requestId != _requestVersion) return;
      emit(CountryState(
        status: CountryStatus.failure,
        countries: state.countries,
        query: query,
        message: error.toString(),
      ));
    }
  }

  // retry giữ nguyên từ khóa , if rỗng thì tải ds gợi ý
  void _onRetry(
    CountryRetryRequested event,
    Emitter<CountryState> emit,
  ) {
    if (state.query.isEmpty) {
      add(const CountryStarted());
    } else {
      add(CountrySearchRequested(state.query));
    }
  }
}
