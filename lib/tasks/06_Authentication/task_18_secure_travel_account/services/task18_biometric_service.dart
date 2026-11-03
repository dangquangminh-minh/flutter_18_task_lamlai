import 'package:local_auth/local_auth.dart';

class Task18BiometricService {
  Task18BiometricService({
    LocalAuthentication? auth, }) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  // kiểm tra thiết bị có hỗ trợ và đã đăng ký sinh trắc học
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();

      final canCheck = await _auth.canCheckBiometrics;

      final biometrics = await _auth.getAvailableBiometrics();

      return supported && canCheck && biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // yêu cầu sinh trắc học thiết bị trước khi hiển thị dữ liệu cá nhân.
  Future<bool> authenticate() async {
    try {
      if (!await isAvailable()) {
        return false;
      }

      return await _auth.authenticate( localizedReason:
            'Xác thực để mở dữ liệu cá nhân đã lưu trên thiết bị.',
        biometricOnly: true, persistAcrossBackgrounding: true, );
    } on LocalAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
