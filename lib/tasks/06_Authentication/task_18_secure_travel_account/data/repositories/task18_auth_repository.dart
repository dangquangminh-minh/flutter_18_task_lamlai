import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/models/task18_models.dart';
import '../../services/task18_secure_cache_service.dart';
import '../../../chapter6_google_sign_in_initializer.dart';


class Task18AuthException implements Exception {
  const Task18AuthException(this.code,this.message);
  final String code;
  final String message;
  @override
  String toString()=>message;
}

class Task18AuthRepository {
  Task18AuthRepository({
    FirebaseAuth? firebaseAuth, required this._cache,
  }) : _auth=firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  final Task18SecureCacheService _cache;
  final GoogleSignIn _google=GoogleSignIn.instance;

  User? get currentUser=>_auth.currentUser;
  Stream<User?> get sessionChanges=>_auth.idTokenChanges();

  // reload firebase session
  Future<User?> restoreSession() async {
    final user=_auth.currentUser;
    if(user==null) return null;
    try {
      await user.reload();
      final refreshed=_auth.currentUser;
      if(refreshed==null) return null;
      await refreshed.getIdToken(false);
      await _cache.saveSessionMarker(refreshed.uid);
      await _cache.updateProfile(Task18Profile.fromFirebase(refreshed));
      return refreshed;
    } on FirebaseAuthException catch(e) {
      if(_isRevoked(e.code)) {
        await _forceLocalLogout();
        return null;
      }
      if(e.code=='network-request-failed') {
        await _cache.saveSessionMarker(user.uid);
        return user;
      }
      throw Task18AuthException(e.code,_friendly(e));
    }
  }

  // lấy gg id token và đổi sang credential firebase
  Future<User> signInWithGoogle() async {
    try {
      await Chapter6GoogleSignInInitializer.ensureInitialized();
      await _google.signOut();
      final googleUser=await _google.authenticate();
      final auth=googleUser.authentication;
      final idToken=auth.idToken;
      if(idToken==null || idToken.isEmpty) {
        throw const Task18AuthException( 'google-config',
          'Không nhận được Google ID token. Kiểm tra OAuth/SHA-1.', );
      }
      final credential=GoogleAuthProvider.credential(idToken:idToken);
      final result=await _auth.signInWithCredential(credential);
      final user=result.user;
      if(user==null) {
        throw const Task18AuthException('missing-user','Không thể tạo phiên đăng nhập.');
      }
      await _cache.saveSessionMarker(user.uid);
      await _cache.updateProfile(Task18Profile.fromFirebase(user));
      return user;
    } on Task18AuthException {
      rethrow;
    } on GoogleSignInException catch(e) {
      final code=e.code.toString().toLowerCase();
      if(code.contains('cancel')) {
        throw const Task18AuthException('google-cancelled','Bạn đã hủy đăng nhập Google.');
      }
      throw Task18AuthException( 'google-sign-in', 'Google Sign-In thất bại: $e', );
    } on FirebaseAuthException catch(e) {
      throw Task18AuthException(e.code,_friendly(e));
    } catch(e) {
      throw Task18AuthException('unknown','Đăng nhập thất bại: $e');
    }
  }

  // ktra lại token 
  Future<void> validateAndRefreshSession() async {
    final user=_auth.currentUser;
    if(user==null) {
      throw const Task18AuthException('signed-out','Phiên đăng nhập đã kết thúc.');
    }
    try {
      await user.reload();
      await _auth.currentUser?.getIdToken(true);
    } on FirebaseAuthException catch(e) {
      if(_isRevoked(e.code)) {
        await _forceLocalLogout();
        throw const Task18AuthException( 'revoked',
          'Phiên đăng nhập không còn hợp lệ. Vui lòng đăng nhập lại.', );
      }
      if(e.code=='network-request-failed') rethrow;
      throw Task18AuthException(e.code,_friendly(e));
    }
  }

  // xóa dữ liệu và kết thúc phiên xác thực
  Future<void> signOut() async {
    await _cache.clearSensitive();
    try { await _google.signOut(); } catch(_) {}
    await _auth.signOut();
  }

  // xóa dữ liệu khi token không còn hợp lệ
  Future<void> _forceLocalLogout() async {
    await _cache.clearSensitive();
    try { await _google.signOut(); } catch(_) {}
    await _auth.signOut();
  }



  bool _isRevoked(String code)=>{
    'user-token-expired','invalid-user-token','user-disabled','user-not-found'
  }.contains(code);



  String _friendly(FirebaseAuthException e) {
    switch(e.code) {
      case 'network-request-failed': return 'Không có kết nối mạng.';
      case 'user-disabled': return 'Tài khoản đã bị vô hiệu hóa.';
      case 'invalid-credential': return 'Thông tin xác thực không hợp lệ.';
      case 'account-exists-with-different-credential':
        return 'Email này đang dùng một phương thức đăng nhập khác.';
      default: return e.message ?? 'Không thể xác thực tài khoản.';
    }
  }
}
