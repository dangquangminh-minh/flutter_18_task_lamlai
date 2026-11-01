import 'package:shared_preferences/shared_preferences.dart';

// l.sử 5 thành phố gần nhất
class SearchHistoryService {
  static const String _key = 'task5_recent_cities';


  Future<List<String>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  // tên tìm đc chuyển lên đầu danh sách
  Future<List<String>> addCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];

    //không phân biệt hoa/thường
    current.removeWhere(
      (item) => item.toLowerCase() == city.toLowerCase(),
    );

    current.insert(0, city);

    // lấy 5 mục
    final updated = current.take(5).toList();
    await prefs.setStringList(_key, updated);

    return updated;
  }


  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}