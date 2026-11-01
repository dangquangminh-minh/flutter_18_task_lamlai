import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/repositories/weather_repository.dart';
import '../../data/services/search_history_service.dart';

import '../../domain/models/weather_models.dart';

// 4 trạng thái
enum WeatherViewState {
  initial,
  loading,
  success,
  error,
}


class WeatherController extends ChangeNotifier {
  WeatherController({
    required this._repository,
    required this._historyService,
  });

  final WeatherRepository _repository;
  final SearchHistoryService _historyService;

  WeatherViewState state = WeatherViewState.initial;

  WeatherBundle? weather;
  String? errorMessage;
  List<String> recentCities = [];
  DateTime? selectedDate;

  String? _lastCity;
  bool _lastRequestWasGps = false;
  // mỗi request tăng version để loại lq cũ đến sau
  int _requestVersion = 0;

  //trang mở lần đầu chỉ đọc lịch sử
  Future<void> init() async {
    recentCities = await _historyService.loadHistory();
    notifyListeners();
  }

  // loading -> gọi hai api-> c.nhật thời tiết,l.sử -> success,error
  Future<void> searchCity(String city) async {
    final query = city.trim();

    if (query.isEmpty) {
      return;
    }


    final request = ++_requestVersion;
    _lastCity = query; 
    _lastRequestWasGps = false;
    state = WeatherViewState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.searchCity(query);
      if (request != _requestVersion) return;

      weather = result;
      _lastCity = result.current.cityName;
      _lastRequestWasGps = false;
      selectedDate = _firstForecastDate(result.forecast);

      // api hợp lệ thì lưu l.sử
      recentCities = await _historyService.addCity(
        result.current.cityName,
      );

      state = WeatherViewState.success;
    } catch (e) {
      if (request != _requestVersion) return;
      errorMessage = e.toString();
      state = WeatherViewState.error;
    }

    notifyListeners();
  }


  Future<void> useCurrentLocation() async {
    final request = ++_requestVersion;
    _lastRequestWasGps = true;
    state = WeatherViewState.loading;
    errorMessage = null;
    notifyListeners();

    try {

      final enabled = await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        throw Exception(

          'Dịch vụ vị trí đang tắt. Hãy bật GPS và thử lại.',
        );
      }


      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {

        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Bạn chưa cấp quyền vị trí.');
      }

      // mở cài đặt cấp lại quyền
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Quyền vị trí đã bị từ chối vĩnh viễn. Hãy bật lại trong Cài đặt.',
        );
      }


      final position=await Geolocator.getCurrentPosition(

       locationSettings:const LocationSettings(
          accuracy:LocationAccuracy.high,
        ),
     );

      final result = await _repository.searchCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (request != _requestVersion) return;

      weather = result;
      _lastCity = null;
      _lastRequestWasGps = true;
      selectedDate = _firstForecastDate(result.forecast);

      recentCities = await _historyService.addCity(
        result.current.cityName,
      );

      state = WeatherViewState.success;
    } catch (e) {
      if (request != _requestVersion) return;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = WeatherViewState.error;
    }

    notifyListeners();
  }


  Future<void> refresh() async {
    if (_lastRequestWasGps) {
      await useCurrentLocation();
      return;
    }

    if (_lastCity != null) {
      await searchCity(_lastCity!);
    }
  }

  // dọn l.sử
  Future<void> clearHistory() async {
    await _historyService.clearHistory();
    recentCities = [];
    notifyListeners();
  }

  // đổi ngày dự báo là lọc dữ liệu đã có
  void selectDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  // lọc các nagyf k trùng nhau 
  List<DateTime> get forecastDates {
    final list = weather?.forecast ?? [];
    final result = <DateTime>[];

    for (final item in list) {
      final date = DateTime(
        item.dateTime.year,
        item.dateTime.month,
        item.dateTime.day,
      );

      final exists = result.any(
        (d) => DateUtils.isSameDay(d, date),
      );

      if (!exists) {
        result.add(date);
      }
    }

    return result;
  }

  //trả các mốc thuộc ngày đang chọn để phần dự báo theo ngày h.thị đúng
  List<ForecastItem> get selectedForecast {
    if (selectedDate == null || weather == null) {
      return [];
    }

    return weather!.forecast.where((item) {
      return DateUtils.isSameDay(
        item.dateTime,
        selectedDate,
      );
    }).toList();
  }

  // m.định chọn ngày đầu có dự báo lên ui 
  DateTime? _firstForecastDate(List<ForecastItem> items) {
    if (items.isEmpty) {
      return null;
    }

    final first = items.first.dateTime;

    return DateTime(
      first.year,
      first.month,
      first.day,
    );
  }
}