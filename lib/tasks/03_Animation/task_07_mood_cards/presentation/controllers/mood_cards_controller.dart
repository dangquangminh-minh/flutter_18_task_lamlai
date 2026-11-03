

import 'package:flutter/foundation.dart';
import '../../data/repositories/activity_repository.dart';
import '../../domain/models/activity_model.dart';

enum MoodCardsStatus { initial, loading, success, error }

class MoodCardsController extends ChangeNotifier {
  MoodCardsController({required this._repository});
  final ActivityRepository _repository;

  MoodCardsStatus status = MoodCardsStatus.initial;
  List<ActivityModel> activities = [];
  
  // xài set để cùng một hđ k thể bị thêm trùng vào yêu thích
  final Set<String> favoriteIds = {};
  String selectedType = 'all';

  String? errorMessage;
  bool changingFeatured = false;

  bool _disposed = false;

  //mỗi lần load có token mới
  int _generation = 0;

  void _notify() { if (!_disposed) notifyListeners(); }

// tải lần đầu đổi sang load, lấy hđ và cập nhật state
  Future<void> load() async {
    final token = ++_generation;
    status = MoodCardsStatus.loading;
    errorMessage = null;

    _notify();
    try {
      final items = await _repository.getRandomActivities(count: 5); // gọi repo lấy 5 hđ n.nhiên từ api
      if (_disposed || token != _generation) return; // nếu đã bị dispose, có requet ms hơn thi bỏ qua kq tránh update dl cũ lên ui
      activities = items;

      if (selectedType != 'all' && !items.any((item) => item.type == selectedType)) { // ktra bộ lọc , nếu k còn thì chuyển về t.cả
        selectedType = 'all';
      }
      status = MoodCardsStatus.success;
    } catch (e) {
      if (_disposed || token != _generation) return;
      status = MoodCardsStatus.error;
      errorMessage = e.toString();
    }
    _notify();
  }

// chỉ đổi thẻ được chọn
  Future<void> randomizeFeatured() async {
    if (changingFeatured) return;
    changingFeatured = true;
    errorMessage = null;
    _notify();
    try {
      final activity = await _repository.getRandomActivity();
      if (_disposed) return;
      activities = [activity, ...activities.where((a) => a.id != activity.id)].take(6).toList();
      selectedType = 'all';
    } catch (e) {
      if (!_disposed) errorMessage = e.toString();
    } finally {
      changingFeatured = false;
      _notify();
    }
  }

  Future<void> refresh() => load();
//lọc được th.hiện trên dl hiện có
  void setType(String value) { selectedType = value; _notify(); }

  void toggleFavorite(ActivityModel item) {
    if (!favoriteIds.add(item.id)) favoriteIds.remove(item.id);
    _notify();
  }
  bool isFavorite(ActivityModel item) => favoriteIds.contains(item.id);
  ActivityModel? get featured => activities.isEmpty ? null : activities.first;
  List<ActivityModel> get filteredActivities => selectedType == 'all'
      ? activities
      : activities.where((a) => a.type == selectedType).toList();
  List<String> get availableTypes {
    final values = activities.map((e) => e.type).toSet().toList()..sort();
    return ['all', ...values];
  }
  @override
  void dispose() { _disposed = true; _generation++; super.dispose(); }
}
