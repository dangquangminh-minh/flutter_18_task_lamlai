

import 'package:flutter/material.dart';

class MoodLoadingView extends StatefulWidget {
  const MoodLoadingView({super.key});
  @override
  State<MoodLoadingView> createState() => _MoodLoadingViewState();
}
class _MoodLoadingViewState extends State<MoodLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 850))..repeat(reverse: true);
  }
  @override
  void dispose() { _pulse.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18), children: [
      const Padding(padding: EdgeInsets.only(bottom: 17),
        child: Text('Đang tìm vài hoạt động thú vị cho bạn...',
          style: TextStyle(color: Color(0xFF146B58), fontWeight: FontWeight.w700))),
      ...[190.0, 265.0, 142.0, 142.0].map((height) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: AnimatedBuilder(animation: _pulse, builder: (_, _) =>
          Container(height: height, decoration: BoxDecoration(
            color: Color.lerp(const Color(0xFFE0EDE5), const Color(0xFFF7FBF9),
              MediaQuery.disableAnimationsOf(context) ? .5 : _pulse.value),
            borderRadius: BorderRadius.circular(22))))),
      )]
    );
}
