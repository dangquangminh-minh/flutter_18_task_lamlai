import '../../../domain/models/country_model.dart';

enum CountryStatus {
  initial,
  loading,
  success,
  empty,

  failure,
}

class CountryState {
  const CountryState({
    this.status =
        CountryStatus.initial,
    this.countries = const [],
    this.fromCache = false,
    this.message,

    this.query = '',
  });

  final CountryStatus status;

  final List<CountryModel>
      countries;

  final bool fromCache;

  final String? message;


  final String query;
}