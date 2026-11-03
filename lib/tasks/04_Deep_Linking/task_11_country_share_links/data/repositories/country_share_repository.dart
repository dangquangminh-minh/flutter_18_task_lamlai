

import '../../domain/models/country_share_model.dart';
import '../datasources/country_share_remote_data_source.dart';

class CountryShareRepository {
  CountryShareRepository({
    required this._remote,
  });

  final CountryShareRemoteDataSource _remote;

  Future<List<CountryShareModel>> getCountries({String? region}) {
    return _remote.getCountries(region:region);
  }

  Future<CountryShareModel> getCountry(String code) {
    // chuẩn hóa đầu vào,t.chối code rỗng trước khi request
    final value=code.trim();

    if(value.isEmpty) {
      throw ArgumentError('Country code không được để trống.');
    }

    return _remote.getCountryByCode(value);
  }

  // fallback cho tr.hợp k có mã ISO h.lệ từ nguồn link

  Future<CountryShareModel> getCountryByName(String name) {
    final value=name.trim();

    if(value.isEmpty) {
      throw ArgumentError('Tên quốc gia không được để trống.');
    }

    return _remote.getCountryByName(value);
  }
}