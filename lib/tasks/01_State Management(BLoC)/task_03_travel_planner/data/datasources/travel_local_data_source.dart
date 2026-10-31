import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/country_model.dart';
import '../../domain/models/weather_model.dart';

// lưu dl bằng hive
class TravelLocalDataSource {
  static const _boxName='task3_travel_cache_v2';

  Future<Box<dynamic>> _box() async {
    if(Hive.isBoxOpen(_boxName)) return Hive.box<dynamic>(_boxName);

    return Hive.openBox<dynamic>(_boxName);
  }

  String _countryKey(String query) {

    return 'countries_${Uri.encodeComponent(query.toLowerCase().trim())}';
  }

  String _weatherKey(String code)=>'weather_${code.toUpperCase()}';

   // cache theo từ khóa và lưu ds gần nhất để h.thị off
    Future<void> cacheCountries(
    String query,
    List<CountryModel> countries,
    ) async {
    final box=await _box();
    final data=countries.map((e)=>e.toJson()).toList();

    await box.put(_countryKey(query),data);
    await box.put('last_countries',data);
    await _saveSyncTime(box);
  }

  // tìm cache theo từ khóa
  Future<List<CountryModel>> getCachedCountries(String query) async {
    final box=await _box();

    dynamic raw=box.get(_countryKey(query));
    raw ??=box.get('last_countries');

    if(raw is! List) return [];

    final countries=raw
        .whereType<Map>()
        .map((e)=>CountryModel.fromJson(Map<String,dynamic>.from(e)))
        .toList();

    if(query.trim().isEmpty || query=='__featured__') return countries;

    final q=query.toLowerCase().trim();

    return countries.where((country) {
      return country.name.toLowerCase().contains(q) ||country.capital.toLowerCase().contains(q) ||country.code.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> cacheWeather(String code,WeatherModel weather) async {
    final box=await _box();
    await box.put(_weatherKey(code),weather.toJson());
    
    await _saveSyncTime(box);
  }

  Future<WeatherModel?> getCachedWeather(String code) async {
    final box=await _box();
    final raw=box.get(_weatherKey(code));

    if(raw is! Map) return null;

    return WeatherModel.fromJson(Map<String,dynamic>.from(raw));
  }

  Future<List<CountryModel>> getFavorites() async {
    final box=await _box();
    final raw=box.get('favorites',defaultValue:<dynamic>[]);

    if(raw is! List) return [];

    return raw
        .whereType<Map>()
        .map((e)=>CountryModel.fromJson(Map<String,dynamic>.from(e)))
        .toList();
  }

  Future<void> saveFavorite(CountryModel country) async {
    final box=await _box();
    final favorites=await getFavorites();

    favorites.removeWhere((e)=>e.code==country.code);
    favorites.add(country);

    await box.put(
      'favorites',
      favorites.map((e)=>e.toJson()).toList(),
    );
  }

  Future<void> removeFavorite(String code) async {
    final box=await _box();
    final favorites=await getFavorites();

    favorites.removeWhere((e)=>e.code==code);

    await box.put(
      'favorites',
      favorites.map((e)=>e.toJson()).toList(),
    );
  }

  Future<void> _saveSyncTime(Box<dynamic> box) async {
    await box.put('last_sync',DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastSync() async {
    final box=await _box();
    final raw=box.get('last_sync');

    if(raw==null) return null;
    return DateTime.tryParse(raw.toString());
  }

  // xóa cache mang , k xóa ds yêu thích
  Future<void> clearTemporaryCache() async {
    final box=await _box();

    for(final key in box.keys.toList()) {
      final value=key.toString();

      if(
        value.startsWith('countries_') ||
        value.startsWith('weather_') ||
        value=='last_countries'
      ) {
        await box.delete(key);
      }
    }
  }
}