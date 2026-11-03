

import 'package:flutter/foundation.dart';
import '../../data/repositories/motion_travel_repository.dart';
import '../../domain/models/travel_country.dart';

enum MotionTravelStatus { initial, loading, success, error }

class MotionTravelController extends ChangeNotifier {
  MotionTravelController({required this._repository});
  final MotionTravelRepository _repository;
  MotionTravelStatus status = MotionTravelStatus.initial;
  List<TravelCountry> countries = [];
  Map<String, String> heroUrls = {};
  String searchQuery = '';
  String selectedRegion = 'all';
  bool isOffline = false;
  // phân biệt dl cache và dữ liệu mới để gắn nhãn c.xác trên ui
  bool fromCache = false;
  DateTime? cachedAt;
  String? errorMessage;

  bool _disposed = false;
  int _generation = 0;

  bool _hydrating = false;
  bool _hydrateAgain = false;
  
  final Set<String> _attemptedHero = {};
  final regions = const {
    'all': 'Tất cả', 'Asia': 'Châu Á', 'Europe': 'Châu Âu',
    'Americas': 'Châu Mỹ', 'Africa': 'Châu Phi', 'Oceania': 'Châu Đại Dương',
  };
  void _notify() { if (!_disposed) notifyListeners(); }


// nạp danh sách b.đầu
  Future<void> load() async {
    final request = ++_generation;
    status = MotionTravelStatus.loading;
    errorMessage = null;
    _notify();
    try {
      //   luôn thử api cũ trước,nếu lỗi hoặc off thì đọc hive
      final result = await _repository.loadCountries();
      if (_disposed || request != _generation) return;
      _attemptedHero.clear();
      countries = result.countries;
      heroUrls = result.heroUrls;
      isOffline = result.isOffline;
      fromCache = result.fromCache;
      cachedAt = result.cachedAt;


      status = MotionTravelStatus.success;
      _notify();
      await hydrateVisibleHeroImages();
    } catch (e) {

      if (_disposed || request != _generation) return;
      errorMessage = e.toString();
      status = MotionTravelStatus.error;
      _notify();
    }
  }
  Future<void> refresh() => load();
  void setSearch(String text) {
    searchQuery = text.trim().toLowerCase();
    _notify();
  }
  Future<void> setRegion(String region) async {
    selectedRegion = region;
    _notify();
    await hydrateVisibleHeroImages();
  }
  List<TravelCountry> get filteredCountries {
    Iterable<TravelCountry> visible = countries;
    if (selectedRegion != 'all') {
      visible = visible.where((c) => c.region == selectedRegion);
    }
    if (searchQuery.isNotEmpty) {
      visible = visible.where((c) =>
        c.name.toLowerCase().contains(searchQuery) ||c.capital.toLowerCase().contains(searchQuery));
    }
    // giữ ds vừa đủ
    return visible.take(24).toList();
  }

  Future<void> hydrateVisibleHeroImages() async {
    if (_disposed || isOffline || status != MotionTravelStatus.success) return;
    if (_hydrating) {
      // đổi bộ lọc giữa lúc tải ảnh
      _hydrateAgain = true;
      return;
    }
    _hydrating = true;
    try {
      for (final country in filteredCountries.take(6)) {
        if (_disposed || isOffline) break;
        if (heroUrls.containsKey(country.cca2) ||
            !_attemptedHero.add(country.cca2)) {
          continue;
        }
        final url = await _repository.getHeroImage(country);
        if (_disposed) return;
        
        if (url != null && url.isNotEmpty) {
          heroUrls[country.cca2] = url;
          _notify();
        }
      }
    } finally {
      _hydrating = false;
      if (_hydrateAgain && !_disposed) {
        _hydrateAgain = false;

        Future<void>.microtask(hydrateVisibleHeroImages);
      }
    }
  }
  String? heroFor(TravelCountry country) => heroUrls[country.cca2];
  @override
  void dispose() { _disposed = true; _generation++; super.dispose(); }
}
