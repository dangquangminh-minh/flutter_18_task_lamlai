

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MotionTravelLoadingView extends StatelessWidget {
  const MotionTravelLoadingView({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
    for (int index = 0; index < 3; index++)
      Padding(padding: const EdgeInsets.only(bottom: 14),
        child: Builder(builder: (context) {
          final skeleton = Container(height: 220,
            decoration: BoxDecoration(color: const Color(0xFFE5E9F0),
              borderRadius: BorderRadius.circular(22)));
          if (MediaQuery.disableAnimationsOf(context)) return skeleton;
          return skeleton.animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1200.ms, color: Colors.white70);
        })),
  ]);
}
class MotionTravelErrorView extends StatelessWidget {
  const MotionTravelErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(children: [
      const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFB83242)),
      const SizedBox(height: 15),


      const Text('Không tải được điểm đến',
        style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF7B8794))),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded),

      
        label: const Text('Thử lại'),
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB83242))),
      const SizedBox(height: 14),
      const Text('Ứng dụng sẽ đọc cache Hive khi đã có dữ liệu lưu từ lần truy cập trước.',
        textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF88939F), fontSize: 11)),
    ]));
}
