import '../data/datasources/task18_remote_data_source.dart';
import '../data/repositories/task18_auth_repository.dart';
import '../data/repositories/task18_travel_repository.dart';
import 'task18_biometric_service.dart';
import 'task18_network_monitor.dart';
import 'task18_secure_cache_service.dart';


class Task18Dependencies {
  Task18Dependencies._();
  static final instance=Task18Dependencies._();

  late final Task18SecureCacheService cache;
  late final Task18AuthRepository auth;
  late final Task18RemoteDataSource remote;
  late final Task18TravelRepository travel;

  late final Task18NetworkMonitor network;
  late final Task18BiometricService biometric;
  bool _ready=false;

  // k.tạo tài nguyên và đọc c.hình cần thiết trước khi hiển thị dl
  Future<void> initialize() async {
    if(_ready) return;
    cache=Task18SecureCacheService();
    await cache.initialize();
    auth=Task18AuthRepository(cache:cache);
    remote=Task18RemoteDataSource();
    travel=Task18TravelRepository(remote:remote,cache:cache,auth:auth);
    network=Task18NetworkMonitor();
    biometric=Task18BiometricService();
    _ready=true;
  }
}
