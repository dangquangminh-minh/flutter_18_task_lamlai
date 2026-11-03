import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/task18_constants.dart';
import '../../services/task18_dependencies.dart';
import '../widgets/task18_widgets.dart';


class Task18EntryPage extends StatefulWidget {
  const Task18EntryPage({super.key});

  @override
  State<Task18EntryPage> createState() => _Task18EntryPageState();
}

class _Task18EntryPageState extends State<Task18EntryPage> {
  String status = 'Đang khôi phục phiên...';
  String? error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  // firebase reload kiểm tra trạng thái phiên
  Future<void> _bootstrap() async {
    try {
      final deps = Task18Dependencies.instance;
      await deps.initialize();
      final online = await deps.network.isOnline();
      if (mounted) {
        setState(() => status = online
        ? 'Đang xác minh phiên và tài khoản...' : 'Đang kiểm tra phiên cục bộ...');
      }
      final user = await deps.auth.restoreSession();
      if (!mounted) return;
      context.go(user == null ? Task18Constants.loginPath : Task18Constants.accountPath);
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); status = 'Không thể khôi phục phiên.'; });
    }
  }

  @override

  Widget build(BuildContext context) => Scaffold(
    backgroundColor: task18Background,
    body: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 470),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 92, height: 92,
            decoration: BoxDecoration(
              color: task18Primary,
              borderRadius: BorderRadius.circular(27),
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 46),
          ),
          const SizedBox(height: 24),
          const Text('Aegis Travel',
            style: TextStyle(color: task18Text, fontSize: 29, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          const Text('Tài khoản du lịch an toàn',
            style: TextStyle(color: task18SecondaryText, fontSize: 13)),
          const SizedBox(height: 30),
          Task18SurfaceCard(child: Column(children: [
            if (error == null) const CircularProgressIndicator(color: task18Primary),
            if (error != null) const Icon(Icons.error_outline_rounded,
              color: task18Primary, size: 40),
            const SizedBox(height: 19),
            Text(status, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: task18Text, fontWeight: FontWeight.w700)),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: _bootstrap, icon: const Icon(Icons.refresh),
                label: const Text('Thử lại')),
            ],
          ])),
        ]),
      ),
    ))),
  );
}
