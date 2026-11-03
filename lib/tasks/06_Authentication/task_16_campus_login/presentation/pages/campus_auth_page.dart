import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/auth_repository.dart';
import '../controllers/campus_auth_controller.dart';
import '../widgets/campus_auth_widgets.dart';

class CampusAuthPage extends StatefulWidget {
  const CampusAuthPage({super.key, required this.repository});
  final AuthRepository repository;

  @override
  State<CampusAuthPage> createState() => _CampusAuthPageState();
}

class _CampusAuthPageState extends State<CampusAuthPage> {
  late final CampusAuthController controller;

  @override
  void initState() {
    super.initState();
    controller = CampusAuthController(repository: widget.repository);
  }

  @override
  // giải phóng controller và sub khi màn hình k còn sd
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Scaffold(
        backgroundColor: campusBackground,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                children: [
                  _topBar(),
                  const SizedBox(height: 24),
                  _hero(),
                  const SizedBox(height: 20),
                  _form(),
                  const SizedBox(height: 22),
                  _privacyNote(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  // nút home
  Widget _topBar() => Row(
    children: [
      IconButton.filledTonal(
        onPressed: () => context.go('/'),
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Về trang chủ',
      ),
      const Spacer(),
      const Icon(Icons.school_rounded, color: campusGreen, size: 18),
      const SizedBox(width: 8),
      const Text('CAMPUS / BÀI 16', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
    ],
  );




  // vùng giới thiệu
  Widget _hero() => Container(
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF125C4C), Color(0xFF228C74)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: Color(0xFFD8F9D9), size: 26),
            Spacer(),
            Icon(Icons.shield_outlined, color: Colors.white70),
          ],
        ),
        const SizedBox(height: 27),
        const Text('Một tài khoản.\nCả hành trình học tập.',
          style: TextStyle(color: Colors.white, fontSize: 29, height: 1.13, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        const Text('Đăng nhập an toàn với Firebase và quản lý hồ sơ sinh viên.',
          style: TextStyle(color: Color(0xFFE0F5ED), fontSize: 13, height: 1.5)),
      ],
    ),
  );

  Widget _form() => CampusCard(
    padding: const EdgeInsets.all(23),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _modeSelector(),
        const SizedBox(height: 22),
        Text(controller.isRegister ? 'Tạo tài khoản mới' : 'Chào mừng quay lại',
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(controller.isRegister ? 'Điền thông tin để bắt đầu học tập.' : 'Đăng nhập để tiếp tục hồ sơ sinh viên.',
          style: const TextStyle(color: Color(0xFF71827C), fontSize: 12)),
        const SizedBox(height: 22),
        _label('email'),
        const SizedBox(height: 7),
        TextField(
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          autocorrect: false,
          onChanged: controller.emailChanged,
          decoration: _inputDecoration('student@example.com', Icons.alternate_email_rounded,
            error: controller.email.errorText),
        ),
        const SizedBox(height: 16),
        _label('mật khẩu'),
        const SizedBox(height: 7),
        TextField(
          obscureText: controller.obscurePassword,
          onChanged: controller.passwordChanged,
          autofillHints: [controller.isRegister ? AutofillHints.newPassword : AutofillHints.password],
          decoration: _inputDecoration('Tối thiểu 6 ký tự', Icons.lock_outline_rounded,
            error: controller.password.errorText,
            suffix: IconButton(
              icon: Icon(controller.obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: controller.togglePassword,
            )),
        ),
        if (controller.isRegister) ...[
          const SizedBox(height: 16),
          _label('xác nhận mật khẩu'),
          const SizedBox(height: 7),
          TextField(
            obscureText: controller.obscureConfirmPassword,
            onChanged: controller.confirmPasswordChanged,
            decoration: _inputDecoration('Nhập lại mật khẩu', Icons.verified_user_outlined,
              error: controller.confirmPassword.errorText,
              suffix: IconButton(
                icon: Icon(controller.obscureConfirmPassword
                  ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: controller.toggleConfirmPassword,
              )),
          ),
        ] else ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.submitting ? null : controller.forgotPassword,
              child: const Text('Quên mật khẩu?', style: TextStyle(color: campusGreen)),
            ),
          ),
        ],
        if (controller.errorMessage != null) ...[
          const SizedBox(height: 8),
          _notice(controller.errorMessage!, false),
        ],
        if (controller.successMessage != null) ...[
          const SizedBox(height: 8),
          _notice(controller.successMessage!, true),
        ],
        const SizedBox(height: 20),
        SizedBox(
          height: 55,
          child: FilledButton(
            onPressed: controller.submitting ? null : controller.submit,
            style: FilledButton.styleFrom(
              backgroundColor: campusGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: controller.submitting
              ? const SizedBox(width: 23, height: 23, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(controller.isRegister ? 'Tạo tài khoản' : 'Đăng nhập',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(width: 9),
                  const Icon(Icons.arrow_forward_rounded),
                ]),
          ),
        ),
      ],
    ),
  );

  Widget _modeSelector() => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(color: const Color(0xFFF0F5F1), borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      _modeButton('Đăng nhập', CampusAuthMode.login),
      _modeButton('Đăng ký', CampusAuthMode.register),
    ]),
  );

  Widget _modeButton(String label, CampusAuthMode mode) {
    final selected = controller.mode == mode;
    return Expanded(
      child: InkWell(
        onTap: controller.submitting ? null : () => controller.changeMode(mode),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected ? const [BoxShadow(color: Color(0x11000000), blurRadius: 8)] : [],
          ),
          child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(color: selected ? campusGreen : const Color(0xFF778982), fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text.toUpperCase(),
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8));

  InputDecoration _inputDecoration(String hint, IconData icon, {String? error, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      errorText: error,
      prefixIcon: Icon(icon, color: campusGreen),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF5F8F6),
      contentPadding: const EdgeInsets.symmetric(vertical: 17),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE4ECE6))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: campusGreen, width: 1.6)),
    );
  }

  Widget _notice(String message, bool success) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: success ? const Color(0xFFE7F6EA) : const Color(0xFFFFECE8),
      borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(success ? Icons.check_circle_outline : Icons.error_outline,
        color: success ? campusGreen : const Color(0xFFB64030)),
      const SizedBox(width: 9),
      Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
    ]),
  );

  Widget _privacyNote() => const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.lock_outline_rounded, color: Color(0xFF84968E), size: 16),
      SizedBox(width: 6),
      Flexible(child: Text('Mật khẩu được xác thực bởi Firebase, không lưu trong ứng dụng.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF7E9189), fontSize: 11))),
    ],
  );
}
