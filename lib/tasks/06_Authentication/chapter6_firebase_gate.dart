import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


class Chapter6FirebaseGate extends StatefulWidget {
  const Chapter6FirebaseGate({super.key, required this.child});
  final Widget child;

  @override
  State<Chapter6FirebaseGate> createState() => _Chapter6FirebaseGateState();
}

class _Chapter6FirebaseGateState extends State<Chapter6FirebaseGate> {
  static Future<void>? _initialization;
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _initialization ??= _initialize();
  }


  static Future<void> _initialize() async {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  }

  // tải lại dl khi api thất bại or người dùng muốn làm mới
  void _retry() {
    setState(() {
      _initialization = null;
      _future = _initialization = _initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cấu hình xác thực')),
            body: Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cloud_off_rounded, color: Color(0xFFB63B48), size: 58),
                  const SizedBox(height: 18),
                  const Text('Chưa kết nối Firebase',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  const Text('Kiểm tra google-services.json, Firebase Email/Password, Google provider và SHA-1.',
                    textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  SelectableText('${snapshot.error}',
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 18),
                  FilledButton.icon(onPressed: _retry, icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại')),
                ]),
              ),
            )),
          );
        }
        return widget.child;
      },
    );
  }
}
