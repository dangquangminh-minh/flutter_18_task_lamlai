

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/models/travel_country.dart';
import '../../domain/models/travel_weather.dart';
import '../datasources/motion_country_remote_data_source.dart';
import '../datasources/motion_photo_remote_data_source.dart';

import '../datasources/motion_travel_local_data_source.dart';

import '../datasources/motion_weather_remote_data_source.dart';

class MotionTravelLoadResult {
  const MotionTravelLoadResult({
    required this.countries,
    required this.heroUrls,
    required this.isOffline,
    required this.fromCache,
    required this.cachedAt,
  });

  final List<TravelCountry> countries; //ds qg để h.thị

  final Map<String, String> heroUrls; // map mã quốc gia và ủl ảnh d.lịch
  final bool isOffline;
  final bool fromCache;
  final DateTime? cachedAt; // time dl quôc gia lưu gần nhất
}

class MotionTravelRepository {
  MotionTravelRepository({
    required MotionCountryRemoteDataSource countryRemote,
    required MotionPhotoRemoteDataSource photoRemote,
    required MotionWeatherRemoteDataSource weatherRemote,
    required MotionTravelLocalDataSource local,
  }) : _countryRemote = countryRemote,
       _photoRemote = photoRemote,
       _weatherRemote = weatherRemote,
       _local = local;

  final MotionCountryRemoteDataSource _countryRemote;
  final MotionPhotoRemoteDataSource _photoRemote;
  final MotionWeatherRemoteDataSource _weatherRemote;
  final MotionTravelLocalDataSource _local;

  Future<bool> get isOnline async {   // ktra có mạng hay k
    final result = await Connectivity().checkConnectivity();

    return result.any(
      (item) => item != ConnectivityResult.none,
    );
  }

// ưu tiên network,khi off/lỗi gọi cache cục bộ đã lưu
  Future<MotionTravelLoadResult> loadCountries() async {
    final online = await isOnline;


    if (online) {  // thì gọi api lấy ds qg
      try {
        final countries = await _retry(
          _countryRemote.getCountries,
        );

        await _local.saveCountries(countries); // lưu dl dô hive để dùng off

        return MotionTravelLoadResult(
          countries: countries,
          heroUrls: await _local.getHeroUrls(),
          isOffline: false,
          fromCache: false,
          cachedAt: await _local.getCachedAt(),
        );
      } catch (_) {
        // Chuyển xuống cache.
      }
    }

    //dùng cache đã lưu từ trước
    final cached = await _local.getCountries();

    if (cached.isEmpty) {
      throw Exception(
        'Không có mạng và chưa có dữ liệu Hive để đọc offline.',
      );
    }

    return MotionTravelLoadResult(
      countries: cached,
      heroUrls: await _local.getHeroUrls(),
      isOffline: true,
      fromCache: true,
      cachedAt: await _local.getCachedAt(),
    );
  }


  //lây url ảnh du lịch của 1  qg
  Future<String?> getHeroImage(
    TravelCountry country,
  ) async {
    final cachedUrls = await _local.getHeroUrls();

    if (cachedUrls.containsKey(country.cca2)) {
      return cachedUrls[country.cca2];
    }

    if (!await isOnline) {
      return null;
    }

    try {
      final url = await _retry(
        () => _photoRemote.searchHeroImage(country),
      );

      if (url != null && url.isNotEmpty) {
        await _local.saveHeroUrl(country.cca2, url);
      }

      return url;
    } catch (_) {

      // unsplash k trả ảnh thì ui fallback về ảnh cờ
      return null;
    }
  }

  Future<TravelWeather> getWeather(
    TravelCountry country,
  ) {
    return _retry(
      () => _weatherRemote.getWeather(country.capital),
    );
  }

// backoff tăng thời gian chờ sau lỗi tạm thời
  Future<T> _retry<T>(
    Future<T> Function() action, {
    int attempts = 3,
  }) async {
    Object? lastError;

    for (int attempt = 0; attempt < attempts; attempt++) {
      try {
        return await action();
      } catch (e) {
        lastError = e;

        if (attempt == attempts - 1) break;

        final delay = Duration(
          milliseconds: 600 * (1 << attempt),
        );

        // giảm spam api khi gặp lỗi
        await Future.delayed(delay);
      }
    }

    throw lastError ?? Exception('Request thất bại.');
  }
}