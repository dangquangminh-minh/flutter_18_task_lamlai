import '../../domain/models/country_model.dart';

import '../datasources/country_remote_data_source.dart';


class CountryRepository {
  CountryRepository({required CountryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final CountryRemoteDataSource _remoteDataSource;


  Future<List<CountryModel>> getCountries() => _remoteDataSource.fetchCountries();
}
