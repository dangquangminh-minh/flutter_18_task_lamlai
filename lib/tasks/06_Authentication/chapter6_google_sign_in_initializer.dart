import 'package:google_sign_in/google_sign_in.dart';

class Chapter6GoogleSignInInitializer {
  Chapter6GoogleSignInInitializer._();

  static Future<void>? _initialization;

  // khởi tạo gg khi người dùng sử dụng đăng nhập gg
  static Future<void> ensureInitialized() async {
    final future = _initialization ??= GoogleSignIn.instance.initialize();

    try {
      await future;
    } catch (_) {
      if (identical(_initialization, future)) {
        _initialization = null;
      }
      rethrow;
    }
  }
}
