

import 'package:flutter/material.dart';

import '../../data/repositories/country_share_repository.dart';
import '../../domain/models/country_share_model.dart';

enum CountryShareListStatus {
  initial,
  loading,
  success,
  error,
}

class CountryShareListController
    extends ChangeNotifier {
  CountryShareListController({
    required this._repository,
  });

  final CountryShareRepository _repository;

  CountryShareListStatus status =
      CountryShareListStatus.initial;

  List<CountryShareModel> countries = [];

  String? region;
  // k gửi query này lên api, ds đã nhận được lọc trong bn
  String searchQuery = '';
  String? errorMessage;

  // chỉ tìm trong ds tải
  List<CountryShareModel> get filteredCountries {
    final query =
        searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return countries;
    }

    return countries.where((country) {
      return country.name
              .toLowerCase()
              .contains(query) || country.officialName
              .toLowerCase()
              .contains(query) || country.capital
              .toLowerCase()
              .contains(query) ||country.cca2
              .toLowerCase()
              .contains(query) ||country.cca3
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  // gửi load/error để ui h.thị nút retry
  Future<void> load({
    String? region,
  }) async {
    this.region = region;

    status = CountryShareListStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      countries =
          await _repository.getCountries(
        region: region,
      );

      status = CountryShareListStatus.success;
    } catch (e) {
      status = CountryShareListStatus.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  void setSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  // retry giữ lại region vừa chọn để ui kh quay về tất cả

  Future<void> retry() {
    return load(region: region);
  }
}