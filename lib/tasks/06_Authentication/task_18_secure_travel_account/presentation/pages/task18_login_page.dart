import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/task18_auth_repository.dart';
import '../../services/task18_constants.dart';
import '../../services/task18_dependencies.dart';

import '../widgets/task18_widgets.dart';


class Task18LoginPage extends StatefulWidget {
  const Task18LoginPage({super.key});

  @override
  State<Task18LoginPage> createState() => _Task18LoginPageState();
}

class _Task18LoginPageState extends State<Task18LoginPage> {
  bool busy = false;
  bool checkingCache = true;

  bool hasOffline = false;

  String? message;

  @override
  void initState() {
    super.initState();
    _checkOffline();
  }


  Future<void> _checkOffline() async {
    try {
      final deps = Task18Dependencies.instance;
      await deps.initialize();
      final has = await deps.travel.hasOfflineData();
      if (mounted) setState(() { hasOffline = has; checkingCache = false; });
    } catch (e) {
      if (mounted) setState(() { checkingCache = false; message = 'Không đọc được dữ liệu offline: $e'; });
    }
  }

  // firebase cấp phiên đ.nhập thật sau t.công mới chuyển sang trang tk
  Future<void> _login() async {
    if (busy) return;
    setState(() { busy = true; message = null; });
    try {
      await Task18Dependencies.instance.auth.signInWithGoogle();
      if (mounted) context.go(Task18Constants.accountPath);
    } on Task18AuthException catch (e) {
      if (mounted) setState(() => message = e.message);
    } catch (e) {
      if (mounted) setState(() => message = 'Không thể đăng nhập: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }



  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: task18Background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 35),
            children: [
              Row(children: [
                IconButton.filledTonal(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Về trang chủ',
                ),
                const Spacer(),
                const Text('BÀI 18',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 24),
              _hero(),
              const SizedBox(height: 22),
              Task18SurfaceCard(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Text('Truy cập hành trình của bạn',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: task18Text)),
                  const SizedBox(height: 8),
                  const Text('Xác thực Google để cập nhật điểm đến yêu thích và thời tiết.',
                    style: TextStyle(color: task18SecondaryText, height: 1.5, fontSize: 12)),
                  const SizedBox(height: 24),
                  SizedBox(height: 56, child: FilledButton(
                    onPressed: busy ? null : _login,
                    style: FilledButton.styleFrom(
                      backgroundColor: task18Primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: busy
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.account_circle_outlined),
                          SizedBox(width: 10),
                          Text('Đăng nhập với Google', style: TextStyle(fontWeight: FontWeight.w800)),
                        ]),
                  )),
                  if (message != null) ...[
                    const SizedBox(height: 14),
                    _message(message!),
                  ],
                  if (checkingCache) ...[
                    const SizedBox(height: 18),
                    const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ] else if (hasOffline) ...[
                    const SizedBox(height: 20),
                    const Row(children: [
                      Expanded(child: Divider()),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 9),
                        child: Text('hoặc', style: TextStyle(color: task18SecondaryText))),
                      Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: () => context.push(Task18Constants.offlinePath),
                      icon: const Icon(Icons.offline_bolt_rounded),
                      label: const Text('Xem bản lưu ngoại tuyến'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: task18Primary,
                        side: const BorderSide(color: task18Primary),
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text('Dữ liệu nhạy cảm cần xác thực sinh trắc học để mở.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: task18SecondaryText, fontSize: 11)),
                  ],
                ]),
              ),
              const SizedBox(height: 19),
              const Row(children: [
                Icon(Icons.lock_outline_rounded, size: 17, color: task18Primary),
                SizedBox(width: 9),
                Expanded(child: Text('Thông tin được lưu cục bộ  ',
                  style: TextStyle(fontSize: 11, color: task18SecondaryText))),
              ]),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _hero() => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF6F1C2D), Color(0xFFC23E56)]),
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.shield_rounded, color: Color(0xFFFFF0ED), size: 29),
        Spacer(),
        Icon(Icons.travel_explore_rounded, color: Colors.white70, size: 26),
      ]),
      const SizedBox(height: 28),
      const Text('Đi xa hơn.\nAn tâm hơn.',
        style: TextStyle(color: Colors.white, fontSize: 31, height: 1.13, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      const Text('Đăng nhập bảo mật • dữ liệu ngoại tuyến • khôi phục phiên',
        style: TextStyle(color: Color(0xFFFADCE1), fontSize: 12, height: 1.4)),
    ]),
  );

  Widget _message(String value) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFFFEAE9), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: task18Primary),
      const SizedBox(width: 9),
      Expanded(child: Text(value, style: const TextStyle(color: task18Primary, fontSize: 12))),
    ]),
  );
}
