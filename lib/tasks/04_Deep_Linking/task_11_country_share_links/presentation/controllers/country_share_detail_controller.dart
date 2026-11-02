

import 'package:flutter/material.dart';

import '../../data/datasources/country_share_remote_data_source.dart';
import '../../data/repositories/country_share_repository.dart';
import '../../domain/models/country_share_model.dart';

enum CountryShareDetailStatus {
  loading,
  success,
  notFound,
  error,
}

class CountryShareDetailController extends ChangeNotifier {
  CountryShareDetailController({
    required CountryShareRepository repository,
    this.code,
    this.name,
  }) : _repository = repository;

  final CountryShareRepository _repository;
  final String? code;
  final String? name;

  CountryShareDetailStatus status=CountryShareDetailStatus.loading;
  CountryShareModel? country;
  String? errorMessage;



  Future<void> load() async {
    status=CountryShareDetailStatus.loading;
    errorMessage=null;
    notifyListeners();

    final countryCode=code?.trim() ?? '';
    final countryName=name?.trim() ?? '';

    if(countryCode.isEmpty && countryName.isEmpty) {
      status=CountryShareDetailStatus.notFound;
      errorMessage='Không có mã hoặc tên quốc gia để tải.';
      notifyListeners();
      return;
    }

    try {
      if(countryCode.isNotEmpty) {
        country=await _repository.getCountry(countryCode);
      } else {
        country=await _repository.getCountryByName(countryName);
      }

      status=CountryShareDetailStatus.success;
    } on CountryShareNotFoundException {
      status=CountryShareDetailStatus.notFound;

      errorMessage=countryCode.isNotEmpty
          ? 'Không tìm thấy quốc gia có mã $countryCode.'
          : 'Không tìm thấy quốc gia "$countryName".';
    } catch(e) {
      status=CountryShareDetailStatus.error;
      errorMessage=e.toString();
    }

    notifyListeners();
  }
}