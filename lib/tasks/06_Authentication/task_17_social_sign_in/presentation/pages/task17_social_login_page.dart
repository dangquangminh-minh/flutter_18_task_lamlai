import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/task17_auth_repository.dart';
import '../widgets/task17_widgets.dart';


class Task17SocialLoginPage extends StatefulWidget {
  const Task17SocialLoginPage({super.key, required this.repository});
  final Task17AuthRepository repository;

  @override
  State<Task17SocialLoginPage> createState() => _Task17SocialLoginPageState();
}

class _Task17SocialLoginPageState extends State<Task17SocialLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool busy = false;
  bool obscure = true;
  String? errorMessage;
  String? infoMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get validEmail => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(emailController.text.trim());

  //thực hiện gg o auth rồi đổi credential sang firebase auth
  Future<void> googleLogin() async {
    if (busy) return;
    setState(() { busy = true; errorMessage = null; infoMessage = null; });
    try {
      await widget.repository.signInWithGoogle(saveDemoToken: true);
    } on Task17AuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'account-exists-with-different-credential' && widget.repository.pendingEmail != null) {
        emailController.text = widget.repository.pendingEmail!;
      }
      setState(() {
        if (e.code == 'google-cancelled') {
          infoMessage = 'Bạn đã hủy đăng nhập Google.';
        } else {
          errorMessage = e.message;
        }
      });
    } catch (e) {
      if (mounted) setState(() => errorMessage = 'Không thể đăng nhập: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  // đăng nhập email
  Future<void> emailLogin() async {
    if (busy) return;
    if (!validEmail || passwordController.text.length < 6) {
      setState(() => errorMessage = 'Nhập email hợp lệ và mật khẩu từ 6 ký tự.');
      return;
    }
    setState(() { busy = true; errorMessage = null; infoMessage = null; });
    try {
      await widget.repository.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
        saveDemoToken: true,
      );
    } on Task17AuthException catch (e) {
      if (mounted) setState(() => errorMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => errorMessage = 'Không thể đăng nhập: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resetPassword() async {
    if (!validEmail) {
      setState(() => errorMessage = 'Nhập email hợp lệ trước khi đặt lại mật khẩu.');
      return;
    }
    setState(() { busy = true; errorMessage = null; infoMessage = null; });
    try {
      await widget.repository.sendPasswordReset(emailController.text.trim());
      if (mounted) setState(() => infoMessage = 'Đã gửi hướng dẫn đặt lại mật khẩu đến email.');
    } on Task17AuthException catch (e) {
      if (mounted) setState(() => errorMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => errorMessage = 'Gửi email thất bại: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collision = widget.repository.hasPendingGoogleCredential;
    return Scaffold(
      backgroundColor: task17Background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 35),
              children: [
                Row(children: [
                  IconButton.filledTonal(onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_back_rounded), tooltip: 'Về trang chủ'),
                  const Spacer(),
                  const Text('BÀI 17  ',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.6)),
                ]),
                const SizedBox(height: 24),
                _hero(),
                const SizedBox(height: 20),
                Task17Card(
                  padding: const EdgeInsets.all(23),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    const Text('Đăng nhập linh hoạt', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    const Text('Liên kết tài khoản, lưu phiên an toàn và khám phá lịch sử bài viết.',
                      style: TextStyle(color: Color(0xFF85796F), fontSize: 12, height: 1.4)),
                    const SizedBox(height: 24),
                    SizedBox(height: 55, child: OutlinedButton(
                      onPressed: busy ? null : googleLogin,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: task17Text,
                        side: const BorderSide(color: Color(0xFFDDD8D2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: busy ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2)) : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Task17GoogleMark(), SizedBox(width: 10),
                          Text('Tiếp tục với Google', style: TextStyle(fontWeight: FontWeight.w800))],
                      ),
                    )),
                    const SizedBox(height: 23),
                    const Row(children: [
                      Expanded(child: Divider()),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('hoặc đăng nhập bằng email',
                          style: TextStyle(color: Color(0xFF968A82), fontSize: 11))),
                      Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 23),
                    _label('email'),
                    const SizedBox(height: 7),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: _field('you@example.com', Icons.alternate_email_rounded),
                    ),
                    const SizedBox(height: 15),
                    _label('mật khẩu'),
                    const SizedBox(height: 7),
                    TextField(
                      controller: passwordController,
                      obscureText: obscure,
                      autofillHints: const [AutofillHints.password],
                      decoration: _field('Mật khẩu Firebase', Icons.lock_outline_rounded).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                    Align(alignment: Alignment.centerRight, child: TextButton(
                      onPressed: busy ? null : resetPassword,
                      child: const Text('Quên mật khẩu?', style: TextStyle(color: task17Orange)),
                    )),
                    if (collision) _feedback(
                      'Email này đã có phương thức đăng nhập khác. Đăng nhập email để thử liên kết Google.', false),
                    if (errorMessage != null) _feedback(errorMessage!, false),
                    if (infoMessage != null) _feedback(infoMessage!, true),
                    const SizedBox(height: 13),
                    SizedBox(height: 54, child: FilledButton.icon(
                      onPressed: busy ? null : emailLogin,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Đăng nhập bằng email',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                      style: FilledButton.styleFrom(
                        backgroundColor: task17Orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    )),
                  ]),
                ),
                const SizedBox(height: 20),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.security_rounded, color: Color(0xFFB28565), size: 17),
                  SizedBox(width: 7),
                  Flexible(child: Text('Không lưu mật khẩu trong bộ nhớ ứng dụng.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF87766C)))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFC2491D), Color(0xFFF28B43)]),
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.hub_rounded, color: Colors.white, size: 28),
        Spacer(),
        Icon(Icons.verified_user_rounded, color: Colors.white70),
      ]),
      const SizedBox(height: 24),
      const Text('Kết nối bằng\ncách của bạn.',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, height: 1.12, color: Colors.white)),
      const SizedBox(height: 9),
      const Text('Google OAuth • Email/Password • Firebase',
        style: TextStyle(color: Color(0xFFFFE8DC), fontSize: 12)),
    ]),
  );

  Widget _label(String text) => Text(text.toUpperCase(),
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.7));

  InputDecoration _field(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: task17Orange),
    filled: true,
    fillColor: const Color(0xFFFFF8F3),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFF0E6DE))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: task17Orange, width: 1.5)),
  );

  Widget _feedback(String message, bool info) => Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: info ? const Color(0xFFE8F5EF) : const Color(0xFFFFECE6),
      borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(info ? Icons.info_outline_rounded : Icons.error_outline_rounded,
        color: info ? const Color(0xFF168368) : task17Orange),
      const SizedBox(width: 9),
      Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
    ]),
  );
}
