import '../../domain/models/country_model.dart';
import '../../domain/models/weather_model.dart';
import '../../network_info.dart';
import '../datasources/travel_local_data_source.dart';
import '../datasources/travel_remote_data_source.dart';

class TravelData<T> {
  const TravelData({
    required this.data,
    required this.fromCache,
  });

  final T data;
  final bool fromCache;
}

class TravelRepositoryException implements Exception {
  const TravelRepositoryException(this.message);

  final String message;

  @override
  String toString()=>message;
}

// repo lấy dl từ api hay hive
class TravelRepository {
  TravelRepository({
    required this._remote,
    required this._local,
    required this._networkInfo,
  });

  final TravelRemoteDataSource _remote;
  final TravelLocalDataSource _local;
  final NetworkInfo _networkInfo;

  Future<TravelData<List<CountryModel>>> loadFeatured() {
    return _loadCountries(
      cacheKey:'__featured__',
      remoteCall:_remote.loadFeaturedCountries,
    );
  }

  Future<TravelData<List<CountryModel>>> searchCountries(String query) {
    return _loadCountries(
      cacheKey:query,
      remoteCall:()=>_remote.searchCountries(query),
    );
  }


 // có k.nối thì lấy api trc , k đc mới dùng cache
  Future<TravelData<List<CountryModel>>> _loadCountries({
    required String cacheKey,
    required Future<List<CountryModel>> Function() remoteCall,
  }) async {
    final online=await _networkInfo.isConnected;

    if(online) {
      try {
        final data=await remoteCall();
        await _local.cacheCountries(cacheKey,data);

        return TravelData(
          data:data,
          fromCache:false,
        );
      } catch(_) {
        final cached=await _local.getCachedCountries(cacheKey);

        if(cached.isNotEmpty) {
          return TravelData(
            data:cached,
            fromCache:true,
          );
        }

        rethrow;
      }
    }

    final cached=await _local.getCachedCountries(cacheKey);

    if(cached.isEmpty) {
      throw const TravelRepositoryException(
        'Bạn đang ngoại tuyến và chưa có dữ liệu quốc gia được lưu.',
      );
    }

    return TravelData(
      data:cached,
      fromCache:true,
    );
  }


  Future<TravelData<WeatherModel>> loadWeather(CountryModel country) async {
    final online=await _networkInfo.isConnected;

    if(online) {
      try {
        final weather=await _remote.loadWeather(country);
        await _local.cacheWeather(country.code,weather);

        return TravelData(
          data:weather,
          fromCache:false,
        );
      } catch(_) {
        final cached=await _local.getCachedWeather(country.code);

        if(cached!=null) {
          return TravelData(
            data:cached,
            fromCache:true,
          );
        }

        rethrow;
      }
    }

    final cached=await _local.getCachedWeather(country.code);

    if(cached==null) {
      throw const TravelRepositoryException(
        'Chưa có dữ liệu thời tiết ngoại tuyến cho điểm đến này.',
      );
    }

    return TravelData(
      data:cached,
      fromCache:true,
    );
  }

  Future<List<CountryModel>> getFavorites()=>_local.getFavorites();

  Future<void> toggleFavorite(CountryModel country) async {
    final favorites=await _local.getFavorites();
    final exists=favorites.any((e)=>e.code==country.code);

    if(exists) {
      await _local.removeFavorite(country.code);
    } else {
      await _local.saveFavorite(country);
    }
  }

  Future<WeatherModel?> getCachedWeather(String code) {
    return _local.getCachedWeather(code);
  }

  Future<void> syncFavorites() async {
    if(!await _networkInfo.isConnected) {
      throw const TravelRepositoryException(
        'Không có mạng để đồng bộ.',
      );
    }

    final favorites=await getFavorites();

    for(final country in favorites) {
      try {
        final weather=await _remote.loadWeather(country);
        await _local.cacheWeather(country.code,weather);
      } catch(_) {}
    }
  }

  Future<DateTime?> getLastSync()=>_local.getLastSync();

  Future<void> clearCache()=>_local.clearTemporaryCache();
}