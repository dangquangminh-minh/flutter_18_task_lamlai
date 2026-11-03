import 'package:firebase_auth/firebase_auth.dart';


class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth, }) : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // gọi firebase 
  Future<UserCredential> register({
    required String email, required String password, }) {
    return _auth .createUserWithEmailAndPassword( email: email.trim(), password: password, );
  }

  // đ.nhập email = firebase auth
  Future<UserCredential> login({
    required String email, required String password, }) {
    return _auth .signInWithEmailAndPassword( email: email.trim(), password: password, );
  }


  Future<void> logout() {
    return _auth.signOut();
  }

  // gửi thư xác minh đến email
  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception( 'Không tìm thấy người dùng hiện tại.', );
    }

    await user.sendEmailVerification();
  }

  // lấy lại thông tin ng.dùng mới nhất để ktra đã x.minh
  Future<User?> reloadCurrentUser() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    await user.reload();

    return _auth.currentUser;
  }

  // gửi email đặt lại m.khẩu = firebase
  Future<void> sendPasswordReset({
    required String email, }) {
    return _auth .sendPasswordResetEmail( email: email.trim(), );
  }
}
