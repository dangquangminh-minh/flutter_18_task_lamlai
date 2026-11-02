

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/campaign_coordinator.dart';

import '../controllers/campaign_login_controller.dart';

// đăng nhập demo x.nhận dl nhập, kh gửi mật khẩu lên api

class CampaignLoginPage extends StatefulWidget {
  const CampaignLoginPage({super.key});
  @override
  State<CampaignLoginPage> createState() => _CampaignLoginPageState();
}

class _CampaignLoginPageState extends State<CampaignLoginPage> {
  static const dark = Color(0xFF151E23);
  static const lime = Color(0xFFCBF268);
  late CampaignLoginController controller;
  final user = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;

  @override
  void initState() {
    super.initState();
    controller = CampaignLoginController(coordinator: CampaignCoordinator.instance);
  }

  @override
  void dispose() { controller.dispose(); user.dispose(); password.dispose(); super.dispose(); }

  // sau khi login, trả route đang chờ t.vì trở về một id mặc định

  Future<void> _login() async {
    final destination = await controller.login(username: user.text, password: password.text);
    if (!mounted || destination == null) return;
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: controller, builder: (context, _) => Scaffold(
    backgroundColor: const Color(0xFFF2F5EF),
    appBar: AppBar(title: const Text('Xác thực truy cập', style: TextStyle(fontWeight: FontWeight.w800)),
      backgroundColor: const Color(0xFFF2F5EF), surfaceTintColor: Colors.transparent, foregroundColor: dark),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
      Container(padding: const EdgeInsets.all(25), decoration: BoxDecoration(color: dark, borderRadius: BorderRadius.circular(28)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: lime, shape: BoxShape.circle),
            child: const Icon(Icons.lock_open_rounded, color: dark)),
          const SizedBox(height: 20), const Text('Đăng nhập để\ntiếp tục hành trình.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 27, height: 1.18)),
          const SizedBox(height: 12),
          const Text('Deep Link được giữ trong bộ nhớ tạm. Sau khi đăng nhập, ứng dụng sẽ chuyển đúng tới chiến dịch.',
            style: TextStyle(color: Color(0xFFBFCFC6), height: 1.45, fontSize: 12)),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF303F3B),
            borderRadius: BorderRadius.circular(13)),
            child: SelectableText(controller.pendingLink ?? 'Không có link đang chờ.',
              style: const TextStyle(color: lime, fontSize: 12))),
        ])),
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(22)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tài khoản demo', style: TextStyle(color: dark, fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7), const Text('Nhập tên bất kỳ và mật khẩu tối thiểu 4 ký tự để mô phỏng Auth Guard.',
            style: TextStyle(color: Color(0xFF697A71), fontSize: 12)),
          const SizedBox(height: 17), TextField(controller: user,
            decoration: InputDecoration(labelText: 'Tên đăng nhập', prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
          const SizedBox(height: 12), TextField(controller: password, obscureText: obscure,
            decoration: InputDecoration(labelText: 'Mật khẩu demo', prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure),
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
          if (controller.errorMessage != null) ...[
            const SizedBox(height: 10), Text(controller.errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
          const SizedBox(height: 17), SizedBox(width: double.infinity, height: 50,
            child: FilledButton.icon(onPressed: controller.loading ? null : _login,
              style: FilledButton.styleFrom(backgroundColor: dark),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(controller.loading ? 'Đang xác thực...' : 'Đăng nhập & tiếp tục'))),
        ])),
      const SizedBox(height: 15),
      const Text('Đây không phải cơ chế đăng nhập thật. Để dùng production cần hệ thống Auth và lưu token an toàn.',
        textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF68766A), fontSize: 11)),
    ])),
  ));
}
