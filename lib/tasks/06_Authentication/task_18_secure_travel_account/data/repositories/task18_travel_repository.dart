import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/task18_models.dart';
import '../../services/task18_secure_cache_service.dart';
import '../datasources/task18_remote_data_source.dart';
import 'task18_auth_repository.dart';


class Task18TravelRepository {
  Task18TravelRepository({
    required this._remote, required this._cache,
    required this._auth, });

  final Task18RemoteDataSource _remote;
  final Task18SecureCacheService _cache;
  final Task18AuthRepository _auth;

  String get favoriteCountryCode=>_cache.favoriteCountryCode;

  // lấy quốc gia và thời tiết mới
  Future<Task18TravelSnapshot> sync({
    required User user, String? countryCode, }) async {
    await _auth.validateAndRefreshSession();
    final code=countryCode ?? favoriteCountryCode;
    final country=await _remote.fetchCountry(code);
    if(country.capital.isEmpty) {
      throw const Task18RemoteException('Quốc gia này không có thủ đô để tải thời tiết.');
    }
    final weather=await _remote.fetchWeather(country.capital);
    final snapshot=Task18TravelSnapshot( profile:Task18Profile.fromFirebase(user), country:country,   //sau đó lưu snapshot mã hóa.
      weather:weather, updatedAt:DateTime.now(), );
    await _cache.saveSnapshot(snapshot);
    return snapshot;
  }

  Future<Task18TravelSnapshot?> readOffline()=>_cache.readSnapshot();
  Future<bool> hasOfflineData()=>_cache.hasSnapshot();
  Future<void> clearAllCache()=>_cache.clearAll();
}

