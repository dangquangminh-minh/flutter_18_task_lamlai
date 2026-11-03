import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

import '../../data/repositories/auth_repository.dart';
import '../../domain/inputs/auth_inputs.dart';


enum CampusAuthMode {
  login, register, }

class CampusAuthController extends ChangeNotifier {
  CampusAuthController({required this._repository});

  final AuthRepository _repository;

  CampusAuthMode mode = CampusAuthMode.login;
  EmailInput email = const EmailInput.pure();

  PasswordInput password = const PasswordInput.pure();

  ConfirmPasswordInput confirmPassword = const ConfirmPasswordInput.pure();

  bool submitting = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String? errorMessage;
  String? successMessage;

  bool get isRegister => mode == CampusAuthMode.register;

  bool get isCampusEmail => email.value .trim() .toLowerCase() .endsWith( '@campus.edu.vn', );

  bool get isValid {
    final inputs = <FormzInput>[
      email, password, if (isRegister)
        confirmPassword, ];

    return Formz.validate( inputs, );
  }

  // chuyển giữa đ.nhập và đ.ký
  void changeMode( CampusAuthMode value, ) {
    if (mode == value) {
      return;
    }

    mode = value;

    errorMessage = null;
    successMessage = null;

    if (!isRegister) {
      confirmPassword = const ConfirmPasswordInput.pure();
    }

    notifyListeners();
  }

  // update email , kiểm tra định dạng
  void emailChanged( String value, ) {
    email = EmailInput.dirty( value, );

    errorMessage = null;

    notifyListeners();
  }

  // ktra mật khẩu và tính hợp lệ của ô nhập lại
  void passwordChanged( String value, ) {
    password = PasswordInput.dirty( value, );

    if (!confirmPassword.isPure) {
      confirmPassword = ConfirmPasswordInput.dirty( password: value, value: confirmPassword.value, );
    }

    errorMessage = null;

    notifyListeners();
  }

  // s.sánh mật khẩu xác nhận với mật khẩu chính
  void confirmPasswordChanged( String value, ) {
    confirmPassword = ConfirmPasswordInput.dirty( password: password.value, value: value, );

    errorMessage = null;
    notifyListeners();
  }

  void togglePassword() {
    obscurePassword = !obscurePassword;

    notifyListeners();
  }

  void toggleConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }


  void _touchAll() {
    email = EmailInput.dirty( email.value, );

    password = PasswordInput.dirty( password.value, );

    if (isRegister) {
      confirmPassword = ConfirmPasswordInput.dirty( password: password.value, value:
            confirmPassword.value, );
    }
  }



  // ktra form rồi gọi đk/đn, h.thị lỗi dễ hiểu
  Future<void> submit() async {
    _touchAll();

    errorMessage = null;
    successMessage = null;

    if (!isValid) {
      errorMessage = 'Vui lòng kiểm tra lại '
          'thông tin đăng nhập.';

      notifyListeners();
      return;
    }

    submitting = true;

    notifyListeners();

    try {
      if (isRegister) {
        final credential = await _repository.register( email: email.value, password: password.value, );

        await credential.user ?.sendEmailVerification();

        successMessage = 'Đăng ký thành công. '
            'Đã gửi email xác minh.';
      } else {
        await _repository.login( email: email.value, password: password.value, );
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = _firebaseMessage(e);
    } catch (e) {
      errorMessage = 'Có lỗi xảy ra: $e';
    } finally {
      submitting = false;

      notifyListeners();
    }
  }



  // ktra email trước khi yêu cầu gửi link đặt lại m.khẩu
  Future<void> forgotPassword() async {
    email = EmailInput.dirty( email.value, );

    errorMessage = null;
    successMessage = null;

    if (!email.isValid) {
      errorMessage = 'Hãy nhập email hợp lệ trước.';

      notifyListeners();
      return;
    }

    submitting = true;

    notifyListeners();

    try {
      await _repository .sendPasswordReset( email: email.value, );

      successMessage = 'Đã gửi email đặt lại mật khẩu.';
    } on FirebaseAuthException catch (e) {
      errorMessage = _firebaseMessage(e);
    } catch (e) {
      errorMessage = 'Không thể gửi email: $e';
    } finally {
      submitting = false;

      notifyListeners();
    }
  }

  String _firebaseMessage( FirebaseAuthException e, ) {
    switch (e.code) {
      case 'email-already-in-use': return 'Email này đã được đăng ký.';

      case 'invalid-email': return 'Email không hợp lệ.';

      case 'weak-password': return 'Mật khẩu quá yếu.';

      case 'user-not-found': case 'wrong-password': case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';

      case 'user-disabled': return 'Tài khoản đã bị vô hiệu hóa.';

      case 'network-request-failed': return 'Không có kết nối mạng.';

      case 'too-many-requests': return 'Bạn thử quá nhiều lần. '
            'Hãy đợi một lúc rồi thử lại.';

      default: return e.message ?? 'Firebase Authentication gặp lỗi.';
    }
  }
}
