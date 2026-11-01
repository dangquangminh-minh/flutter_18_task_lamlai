

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/activity_model.dart';
import '../widgets/activity_visuals.dart';

class ActivityDetailPage extends StatefulWidget {
  const ActivityDetailPage({super.key, required this.activity,
    required this.isFavorite, required this.onFavoriteChanged});
  final ActivityModel activity;
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteChanged;
  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}
class _ActivityDetailPageState extends State<ActivityDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stagger;
  late bool _favorite;
  static const green = Color(0xFF146B58);
  @override
  void initState() {
    super.initState();
    _favorite = widget.isFavorite;
    // chạy l.luotj nd trên màn hình c.tiết
    _stagger = AnimationController(vsync: this, duration: const Duration(milliseconds: 950))..forward();
  }
  @override
  // dừng ticker/animation khi trang c.tiết bị pop 
  void dispose() { _stagger.dispose(); super.dispose(); }
  Widget _entry(int index, Widget child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final begin = (index * .12).clamp(0.0, .75).toDouble();
    final curve = CurvedAnimation(parent: _stagger,
      curve: Interval(begin, (begin + .27).clamp(0.0, 1.0).toDouble(), curve: Curves.easeOutCubic));
    return FadeTransition(opacity: curve, child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, .16), end: Offset.zero).animate(curve),
      child: child));
  }
  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    return Scaffold(backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(backgroundColor: const Color(0xFFF5F8F6), title: const Text('Chi tiết gợi ý'),
        actions: [IconButton(tooltip: 'Yêu thích',
          onPressed: () {
            HapticFeedback.mediumImpact();
            setState(() => _favorite = !_favorite);
            widget.onFavoriteChanged(_favorite);
          },
          icon: AnimatedSwitcher(duration: const Duration(milliseconds: 240),
            transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
            child: Icon(_favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(_favorite), color: const Color(0xFFD46A83))))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 32), children: [
        Hero(tag: 'activity_image_${activity.id}', child: ClipRRect(
          borderRadius: BorderRadius.circular(25), child: ActivityVisuals.cover(activity.type, height: 260))),
        const SizedBox(height: 24),

        _entry(0, Text(activity.typeLabel.toUpperCase(),

          style: const TextStyle(color: green, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12))),
        const SizedBox(height: 8),
        _entry(1, Text(activity.activity, style: const TextStyle(
          color: Color(0xFF15372F), fontWeight: FontWeight.w900, fontSize: 29, height: 1.17))),
        const SizedBox(height: 12),
        _entry(2, const Text('Một hoạt động nhỏ để ngày hôm nay thú vị hơn.',
          style: TextStyle(color: Color(0xFF6F857D), fontSize: 15))),
        const SizedBox(height: 25),
        _entry(3, _row(Icons.people_alt_outlined, 'Người tham gia', activity.participantLabel)),

        const SizedBox(height: 10),
        _entry(4, _row(Icons.payments_outlined, 'Ngân sách', activity.priceLabel)),

        const SizedBox(height: 10),
        _entry(5, _row(Icons.schedule_rounded, 'Thời lượng', activity.durationLabel)),
        const SizedBox(height: 10),
        _entry(6, _row(Icons.accessibility_new, 'Khả năng tiếp cận', activity.accessibilityLabel)),

        
        const SizedBox(height: 26),
        _entry(7, FilledButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Đã lưu ý tưởng! Bạn có thể bắt đầu bất cứ lúc nào.')));
          },
          icon: const Icon(Icons.rocket_launch_outlined),
          label: const Text('Bắt đầu hoạt động'),
          style: FilledButton.styleFrom(backgroundColor: green, minimumSize: const Size.fromHeight(54)),
        )),
      ]),
    );
  }
  Widget _row(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11), color: const Color(0xFFEAF5EE)), child: Icon(icon, color: green)),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF81938B))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ])),
    ]));
}
