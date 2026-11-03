import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/task17_secure_session_service.dart';
import '../../../chapter6_google_sign_in_initializer.dart';


class Task17AuthException implements Exception {
  const Task17AuthException({
    required this.code, required this.message, });

  final String code;
  final String message;

  @override
  String toString()=>message;
}

class Task17AuthRepository {
  Task17AuthRepository({
    FirebaseAuth? firebaseAuth, Task17SecureSessionService? secureSession,
  })  : _auth=firebaseAuth ?? FirebaseAuth.instance, _secureSession=
            secureSession ?? Task17SecureSessionService();

  final FirebaseAuth _auth;
  final Task17SecureSessionService _secureSession;

  final GoogleSignIn _google=GoogleSignIn.instance;

  AuthCredential? _pendingGoogleCredential;
  String? _pendingEmail;

  Stream<User?> get authStateChanges=> _auth.authStateChanges();

  User? get currentUser=>_auth.currentUser;

  String? get pendingEmail=>_pendingEmail;

  bool get hasPendingGoogleCredential=> _pendingGoogleCredential!=null;

  // lấy google id token 
  Future<UserCredential> signInWithGoogle({
    required bool saveDemoToken, }) async {
    try {
      await Chapter6GoogleSignInInitializer.ensureInitialized();
      final googleUser= await _google.authenticate();

      final googleAuth= googleUser.authentication;

      final idToken=googleAuth.idToken;

      if(idToken==null) {
        throw const Task17AuthException( code:'missing-google-id-token', message:
              'Google không trả về ID Token.', );
      }

      final credential= GoogleAuthProvider.credential( idToken:idToken, );  // và đổi sang credential firebase

      try {
        final result= await _auth.signInWithCredential( credential, );

        _clearPending();

        await _saveSecureSession( result.user, enabled:saveDemoToken, );

        return result;
      } on FirebaseAuthException catch(e) {
        if(e.code== 'account-exists-with-different-credential') {
          _pendingGoogleCredential= e.credential ?? credential;

          _pendingEmail= e.email ?? googleUser.email;

          throw Task17AuthException( code:e.code, message: 'Email $_pendingEmail đã tồn tại '
                'với phương thức đăng nhập khác. '
                'Hãy đăng nhập bằng Email/Password '
                'bên dưới để liên kết Google.', );
        }

        throw _mapFirebaseException(e);
      }
    } on GoogleSignInException catch(e) {
      switch(e.code) {
        case GoogleSignInExceptionCode.canceled: throw const Task17AuthException(
            code:'google-cancelled', message: 'Bạn đã hủy đăng nhập Google.', );

        case GoogleSignInExceptionCode.interrupted: throw const Task17AuthException(
            code:'google-interrupted', message: 'Quá trình Google Sign-In bị gián đoạn.', );

        case GoogleSignInExceptionCode .clientConfigurationError: throw Task17AuthException(
            code:'google-config', message: 'Google OAuth chưa cấu hình đúng. '
                'Kiểm tra SHA-1, package name và '
                'Firebase Google provider.', );

        default: throw Task17AuthException( code:'google-error', message: e.description ??
                'Không thể đăng nhập bằng Google.', );
      }
    }
  }

  // xác thực email và lk gg credential
  Future<UserCredential> signInWithEmail({
    required String email, required String password, required bool saveDemoToken, }) async {
    try {
      final result= await _auth.signInWithEmailAndPassword( email:email.trim(), password:password, );

      final pending=_pendingGoogleCredential;

      if(pending!=null) {
        final conflictEmail= _pendingEmail?.trim().toLowerCase();

        if(conflictEmail== email.trim().toLowerCase()) {
          try {
            await result.user ?.linkWithCredential( pending, );

            _clearPending();
          } on FirebaseAuthException catch(e) {
            if(e.code=='provider-already-linked') {
              _clearPending();
            } else {
              throw Task17AuthException( code:e.code, message: 'Đăng nhập Email thành công '
                    'nhưng chưa liên kết được Google: '
                    '${e.message ?? e.code}', );
            }
          }
        } else {
          _clearPending();
        }
      }

      await _saveSecureSession( _auth.currentUser, enabled:saveDemoToken, );

      return result;
    } on Task17AuthException {
      rethrow;
    } on FirebaseAuthException catch(e) {
      throw _mapFirebaseException(e);
    }
  }

  // gửi email đặt lại mật khẩu bằng firebase.
  Future<void> sendPasswordReset( String email, ) async {
    try {
      await _auth.sendPasswordResetEmail( email:email.trim(), );
    } on FirebaseAuthException catch(e) {
      throw _mapFirebaseException(e);
    }
  }

  // lk tài khoản gg vào người dùng firebase đang đnhập
  Future<void> linkGoogleToCurrentUser() async {
    final user=_auth.currentUser;

    if(user==null) {
      throw const Task17AuthException( code:'not-signed-in', message:'Bạn chưa đăng nhập.', );
    }

    final providers=user.providerData .map((e)=>e.providerId) .toSet();

    if(providers.contains('google.com')) {
      throw const Task17AuthException( code:'provider-already-linked',
        message:'Google đã được liên kết rồi.', );
    }

    try {
      await Chapter6GoogleSignInInitializer.ensureInitialized();
      await _google.signOut();

      final googleUser= await _google.authenticate();

      final idToken= googleUser.authentication.idToken;

      if(idToken==null) {
        throw const Task17AuthException( code:'missing-google-id-token',
          message:'Không lấy được Google ID Token.', );
      }

      final credential= GoogleAuthProvider.credential( idToken:idToken, );

      await user.linkWithCredential( credential, );

      await user.reload();

      if(await _secureSession.hasDemoToken()) {
        await _saveSecureSession( _auth.currentUser, enabled:true, );
      }
    } on GoogleSignInException catch(e) {
      if(e.code== GoogleSignInExceptionCode.canceled) {
        throw const Task17AuthException( code:'google-cancelled', message:'Bạn đã hủy liên kết Google.',
        );
      }

      throw Task17AuthException( code:'google-error', message: e.description ??
            'Không thể mở Google OAuth.', );
    } on FirebaseAuthException catch(e) {
      if(e.code=='credential-already-in-use') {
        throw const Task17AuthException( code:'credential-already-in-use', message:
              'Tài khoản Google này đang thuộc '
              'một Firebase account khác.', );
      }

      throw _mapFirebaseException(e);
    }
  }

  // hủy lk  gg khi tài khoản còn ph.thức xác thực khác
  Future<void> unlinkGoogle() async {
    final user=_auth.currentUser;

    if(user==null) {
      return;
    }

    final providers=user.providerData .map((e)=>e.providerId) .toSet();

    if(!providers.contains('google.com')) {
      throw const Task17AuthException( code:'no-such-provider',
        message:'Tài khoản chưa liên kết Google.', );
    }

    // kh cho unlink nếu gg là login duy nhất
    if(!providers.contains('password')) {
      throw const Task17AuthException( code:'unsafe-unlink', message:
            'Không thể hủy Google vì tài khoản '
            'chưa có Email/Password làm phương thức dự phòng.', );
    }

    try {
      await user.unlink('google.com');
      await _google.signOut();
      await user.reload();

      if(await _secureSession.hasDemoToken()) {
        await _saveSecureSession( _auth.currentUser, enabled:true, );
      }
    } on FirebaseAuthException catch(e) {
      throw _mapFirebaseException(e);
    }
  }

  Future<bool> hasSecureDemoToken() {
    return _secureSession.hasDemoToken();
  }

  // kết thúc phiên firebase trên thiết bị.
  Future<void> logout() async {
    await _secureSession.clear();

    try {
      await _google.signOut();
    } catch(_) {}

    await _auth.signOut();

    _clearPending();
  }

  // lưu token demo vào kho
  Future<void> _saveSecureSession( User? user, {
    required bool enabled, }) async {
    if(!enabled) {
      await _secureSession.clear();
      return;
    }

    if(user==null) {
      return;
    }

    final token=await user.getIdToken(true);

    if(token==null || token.isEmpty) {
      return;
    }

    final providers=user.providerData .map((e)=>e.providerId) .join(',');

    await _secureSession.save( token:token, uid:user.uid, email:user.email ?? '', provider:providers, );
  }

  void _clearPending() {
    _pendingGoogleCredential=null;
    _pendingEmail=null;
  }

  Task17AuthException _mapFirebaseException( FirebaseAuthException e, ) {
    final message=switch(e.code) {
      'invalid-email'=> 'Email không đúng định dạng.',

      'invalid-credential'=> 'Email hoặc mật khẩu không đúng.',

      'wrong-password'=> 'Email hoặc mật khẩu không đúng.',

      'user-not-found'=> 'Không tìm thấy tài khoản này.',

      'user-disabled'=> 'Tài khoản đã bị vô hiệu hóa.',

      'network-request-failed'=> 'Không có kết nối mạng.',

      'too-many-requests'=> 'Bạn thử quá nhiều lần. Hãy thử lại sau.',

      'operation-not-allowed'=> 'Phương thức đăng nhập chưa được bật '
        'trong Firebase Console.',

      'provider-already-linked'=> 'Provider đã được liên kết.',

      'credential-already-in-use'=> 'Credential này đang thuộc tài khoản khác.',

      _=> e.message ?? 'Firebase Authentication gặp lỗi.', };

    return Task17AuthException( code:e.code, message:message, );
  }
}
