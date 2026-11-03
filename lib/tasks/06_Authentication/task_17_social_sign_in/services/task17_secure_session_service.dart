import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class Task17SecureSessionService {
  Task17SecureSessionService();

  final FlutterSecureStorage _storage= FlutterSecureStorage( aOptions:const AndroidOptions(
      storageNamespace:'task17_social_session', ), );

  static const _tokenKey='task17_demo_id_token';
  static const _uidKey='task17_uid';
  static const _emailKey='task17_email';
  static const _providerKey='task17_provider';

  Future<void> save({
    required String token, required String uid, required String email, required String provider,
  }) async {
    await Future.wait([
      _storage.write( key:_tokenKey, value:token, ), _storage.write( key:_uidKey, value:uid, ),
      _storage.write( key:_emailKey, value:email, ), _storage.write( key:_providerKey, value:provider, ),
    ]);
  }

  Future<bool> hasDemoToken() async {
    return await _storage.containsKey( key:_tokenKey, );
  }

  Future<void> clear() {
    return _storage.deleteAll();
  }
}
