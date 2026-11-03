import '../../domain/models/country_model.dart';

import '../datasources/country_remote_data_source.dart';


class CountryRepository {
  CountryRepository({required this._remoteDataSource});

  final CountryRemoteDataSource _remoteDataSource;


  Future<List<CountryModel>> getCountries() => _remoteDataSource.fetchCountries();
}
