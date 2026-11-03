import 'package:connectivity_plus/connectivity_plus.dart';

// đọc trạng thái kết nối để chuyển giữa onl và offl
class Task18NetworkMonitor {
  Task18NetworkMonitor({Connectivity? connectivity})
      : _connectivity=connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> isOnline() async {
    final r=await _connectivity.checkConnectivity();
    return !r.contains(ConnectivityResult.none);
  }

  Stream<bool> get onlineChanges=>_connectivity.onConnectivityChanged
      .map((r)=>!r.contains(ConnectivityResult.none)) .distinct();
}
