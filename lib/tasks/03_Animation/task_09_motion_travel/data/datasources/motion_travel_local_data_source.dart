

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/travel_country.dart';

// api lỗi,kh có mạng,repo lấy dl từ đây
class MotionTravelLocalDataSource {
  static const boxName = 'task9_motion_travel';

  Box<dynamic>? _box;

  // mở hove
  Future<Box<dynamic>> get box async {
    _box ??= await Hive.openBox<dynamic>(boxName);
    return _box!;
  }


  // lưu ds qg vừa tải từ api
  Future<void> saveCountries(
    List<TravelCountry> countries,
  ) async {
    final storage = await box;

    await storage.put(
      'countries',
      countries.map((e) => e.toMap()).toList(),
    );

    await storage.put(
      'cachedAt',
      DateTime.now().toIso8601String(),
    );
  }

  Future<List<TravelCountry>> getCountries() async {
    final storage = await box;
    final raw = storage.get('countries');

    if (raw is! List) return [];

    return raw.map((item) {
      return TravelCountry.fromMap(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  Future<DateTime?> getCachedAt() async { // lấy thời điểm cache để h.thị t.tin dl
    final storage = await box;
    final value = storage.get('cachedAt');

    if (value is! String) return null;

    return DateTime.tryParse(value);
  }

  Future<Map<String, String>> getHeroUrls() async {
    final storage = await box;
    final raw = storage.get('heroUrls');

    if (raw is! Map) return {};

    return raw.map(
      (key, value) => MapEntry(
        key.toString(),
        value.toString(),
      ),
    );
  }

  Future<void> saveHeroUrl(
    String cca2,
    String url,
  ) async {
    final storage = await box;

    final urls = await getHeroUrls();
    urls[cca2] = url;

    await storage.put('heroUrls', urls);
  }
}