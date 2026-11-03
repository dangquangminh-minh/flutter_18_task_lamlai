import 'package:formz/formz.dart';


enum EmailValidationError {
  empty, invalid, }

class EmailInput extends FormzInput<String, EmailValidationError> {
  const EmailInput.pure() : super.pure('');

  const EmailInput.dirty([
    super.value = '', ]) : super.dirty();

  static final RegExp _emailRegex = RegExp( r'^[^@\s]+@[^@\s]+\.[^@\s]+$', );

  @override
  EmailValidationError? validator( String value, ) {
    final email = value.trim();

    if (email.isEmpty) {
      return EmailValidationError.empty;
    }

    if (!_emailRegex.hasMatch(email)) {
      return EmailValidationError.invalid;
    }

    return null;
  }

  String? get errorText {
    switch (displayError) {
      case EmailValidationError.empty: return 'Vui lòng nhập email.';
      case EmailValidationError.invalid: return 'Email không đúng định dạng.';
      case null: return null;
    }
  }
}

enum PasswordValidationError {
  empty, tooShort, }

class PasswordInput extends FormzInput< String, PasswordValidationError> {
  const PasswordInput.pure()
      : super.pure('');

  const PasswordInput.dirty([
    super.value = '', ]) : super.dirty();

  @override
  PasswordValidationError? validator( String value, ) {
    if (value.isEmpty) {
      return PasswordValidationError.empty;
    }

    if (value.length < 6) {
      return PasswordValidationError.tooShort;
    }

    return null;
  }

  String? get errorText {
    switch (displayError) {
      case PasswordValidationError.empty: return 'Vui lòng nhập mật khẩu.';
      case PasswordValidationError.tooShort: return 'Mật khẩu phải có ít nhất 6 ký tự.';
      case null: return null;
    }
  }
}

enum ConfirmPasswordValidationError {
  empty, mismatch, }

class ConfirmPasswordInput extends FormzInput< String, ConfirmPasswordValidationError> {
  const ConfirmPasswordInput.pure({
    this.password = '', }) : super.pure('');

  const ConfirmPasswordInput.dirty({
    required this.password, String value = '', }) : super.dirty(value);

  final String password;

  @override
  ConfirmPasswordValidationError? validator( String value, ) {
    if (value.isEmpty) {
      return ConfirmPasswordValidationError.empty;
    }

    if (value != password) {
      return ConfirmPasswordValidationError.mismatch;
    }

    return null;
  }

  String? get errorText {
    switch (displayError) {
      case ConfirmPasswordValidationError.empty: return 'Vui lòng xác nhận mật khẩu.';
      case ConfirmPasswordValidationError.mismatch: return 'Mật khẩu xác nhận không khớp.';
      case null: return null;
    }
  }
}
