import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../services/task18_network_monitor.dart';
import '../../domain/models/task18_models.dart';
import '../../data/repositories/task18_auth_repository.dart';
import '../../data/repositories/task18_travel_repository.dart';


enum Task18ViewState {loading,ready,offline,empty,error,revoked}

class Task18TravelController extends ChangeNotifier {
  Task18TravelController({
    required this._travel, required this._auth,
    required this._network, });

  final Task18TravelRepository _travel;
  final Task18AuthRepository _auth;

  final Task18NetworkMonitor _network;
  StreamSubscription<bool>? _sub;

  Task18ViewState state=Task18ViewState.loading;
  Task18TravelSnapshot? snapshot;
  String? errorMessage;

  bool online=true;
  bool refreshing=false;


  Future<void> initialize(User user) async {
    state=Task18ViewState.loading; errorMessage=null; notifyListeners();
    online=await _network.isOnline();
    _sub ??=_network.onlineChanges.listen((value){
      final becameOnline=!online && value;
      online=value;
      notifyListeners();
      if(becameOnline && state==Task18ViewState.offline) refresh(user);
    });
    if(online) {
      await _syncOrFallback(user);
    } else {
      await _loadOffline();
    }
  }

  //làm mới dlnếu mất mạng thì dùng bản đã lưu
  Future<void> refresh(User user) async {
    if(refreshing) return;
    refreshing=true; errorMessage=null; notifyListeners();
    online=await _network.isOnline();
    if(online) {
      await _syncOrFallback(user);
    } else {
      await _loadOffline(message:'Không có mạng. Đang dùng dữ liệu đã lưu.');
    }
    refreshing=false; notifyListeners();
  }

  // đổi qg và chỉ gọi api khi có kết nối
  Future<void> changeFavorite(User user,String code) async {
    if(!online) {
      errorMessage='Ngoại tuyến chỉ cho phép xem dữ liệu đã lưu.';
      notifyListeners();
      return;
    }
    refreshing=true; errorMessage=null; notifyListeners();
    try {
      snapshot=await _travel.sync(user:user,countryCode:code);
      state=Task18ViewState.ready;
    } on Task18AuthException catch(e) {
      if(e.code=='revoked' || e.code=='signed-out') state=Task18ViewState.revoked;
      errorMessage=e.message;
    } catch(e) {
      errorMessage=e.toString();
    } finally {
      refreshing=false; notifyListeners();
    }
  }

  // ưu tiên dl mới,nếu lỗi thì chuyển sang bản đã lưu
  Future<void> _syncOrFallback(User user) async {
    try {
      snapshot=await _travel.sync(user:user);
      state=Task18ViewState.ready;
      errorMessage=null;
    } on Task18AuthException catch(e) {
      if(e.code=='network-request-failed') {
        await _loadOffline(message:'Không thể xác minh phiên qua mạng. Đang dùng cache.');
        return;
      }
      if(e.code=='revoked' || e.code=='signed-out') {
        state=Task18ViewState.revoked; errorMessage=e.message; notifyListeners(); return;
      }
      await _loadOffline(message:e.message);
    } catch(e) {
      await _loadOffline(message:e.toString());
    }
    notifyListeners();
  }

  // chỉ hiển thị bản cũ và đánh dấu trạng thái offl
  Future<void> _loadOffline({String? message}) async {
    final cached=await _travel.readOffline();
    if(cached==null) {
      snapshot=null;
      state=online ? Task18ViewState.error : Task18ViewState.empty;
      errorMessage=message ??
          (online ? 'Không tải được dữ liệu.' : 'Chưa có dữ liệu offline. Hãy kết nối mạng ít nhất một lần.');
    } else {
      snapshot=cached;
      state=Task18ViewState.offline;
      errorMessage=message;
    }
    notifyListeners();
  }


  Future<void> simulateRevokedSessionDemo() async {
    await _auth.signOut();
    state=Task18ViewState.revoked;
    errorMessage='Demo: phiên đã bị thu hồi. Route guard yêu cầu đăng nhập lại.';
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
