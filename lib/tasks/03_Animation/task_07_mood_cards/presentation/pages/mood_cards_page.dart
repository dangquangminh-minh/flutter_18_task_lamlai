

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/activity_repository.dart';
import '../../domain/models/activity_model.dart';
import '../controllers/mood_cards_controller.dart';
import '../widgets/mood_activity_card.dart';
import '../widgets/mood_loading_view.dart';
import 'activity_detail_page.dart';

class MoodCardsPage extends StatefulWidget {
  const MoodCardsPage({super.key, required this.repository});
  final ActivityRepository repository;
  @override
  State<MoodCardsPage> createState() => _MoodCardsPageState();
}

class _MoodCardsPageState extends State<MoodCardsPage> {
  late final MoodCardsController controller;
  static const green = Color(0xFF146B58);
  @override
  void initState() {
    super.initState();
    controller = MoodCardsController(repository: widget.repository)..load();
  }
  @override
  void dispose() { controller.dispose(); super.dispose(); }

  Future<void> _surprise() async {
    HapticFeedback.selectionClick();
    await controller.randomizeFeatured();
    if (mounted && controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(controller.errorMessage!), action: SnackBarAction(
          label: 'Thử lại', onPressed: _surprise)));
    }
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller, builder: (context, _) => Scaffold(
      backgroundColor: const Color(0xFFF3F8F5),
      appBar: AppBar(backgroundColor: const Color(0xFFF3F8F5),
        surfaceTintColor: Colors.transparent,
        title: const Text('Mood Cards', style: TextStyle(color: Color(0xFF183D34), fontWeight: FontWeight.w900)),
        actions: [Padding(padding: const EdgeInsets.only(right: 16),
          child: Chip(avatar: const Icon(Icons.favorite_rounded, color: Color(0xFFD46A83), size: 16),
            label: Text('${controller.favoriteIds.length}'),
            backgroundColor: Colors.white, side: BorderSide.none))]),
      body: switch (controller.status) {
        MoodCardsStatus.initial || MoodCardsStatus.loading => const MoodLoadingView(),
        MoodCardsStatus.error => _error(),
        MoodCardsStatus.success => _success(),
      },
    ),
  );

// chỉ chạy khi controller có dl hợp lệ
  Widget _success() {
    final featured = controller.featured;
    final list = controller.filteredActivities;
    return RefreshIndicator(
      color: green, onRefresh: controller.refresh,
      child: ListView(physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 36), children: [
          Container(padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(colors: [Color(0xFF155E50), Color(0xFF36A48D)])),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [


              const Text('YOUR DAILY SPARK', style: TextStyle(color: Color(0xFFC0F3D9), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.9)),
              const SizedBox(height: 8),
              const Text('Hôm nay bạn muốn\nlàm gì thú vị?', style: TextStyle(color: Colors.white, fontSize: 27, height: 1.18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Chọn một ý tưởng và bắt đầu từ điều nhỏ nhất.', style: TextStyle(color: Color(0xFFE6FFF2), fontSize: 12)),

              const SizedBox(height: 18),
              
              FilledButton.icon(onPressed: controller.changingFeatured ? null : _surprise,
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: green),
                icon: controller.changingFeatured ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.casino_outlined),
                label: const Text('Gợi ý bất ngờ')),
            ])),
          const SizedBox(height: 24),
          Row(children: [const Expanded(child: Text('Chọn tâm trạng',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF183D34)))),
            Text('${controller.activities.length} ý tưởng', style: const TextStyle(fontSize: 12, color: Color(0xFF6F8F83)))]),
          const SizedBox(height: 11),
          SizedBox(height: 40, child: ListView.separated(scrollDirection: Axis.horizontal,
            itemCount: controller.availableTypes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {

              final type = controller.availableTypes[i], selected = controller.selectedType == type;
              final label = type == 'all' ? 'Tất cả' : controller.activities.firstWhere((a) => a.type == type).typeLabel;
              return ChoiceChip(label: Text(label), showCheckmark: false,
                side: BorderSide.none, selected: selected, selectedColor: green,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF2B5B4B), fontWeight: FontWeight.w700),
                onSelected: (_) { HapticFeedback.selectionClick(); controller.setType(type); });
            })),
          const SizedBox(height: 23),
          if (featured != null && controller.selectedType == 'all') ...[
            const Text('Được chọn cho bạn', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF183D34))),
            const SizedBox(height: 12),
            AnimatedSwitcher(duration: const Duration(milliseconds: 430),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation,
                child: ScaleTransition(scale: Tween(begin: .96, end: 1.0).animate(animation), child: child)),

              child: MoodActivityCard(key: ValueKey(featured.id), activity: featured, featured: true,
                isFavorite: controller.isFavorite(featured),
                onFavorite: () => controller.toggleFavorite(featured),
                onOpen: () => _openDetail(featured))),
            const SizedBox(height: 25),
          ],
          Row(children: [const Expanded(child: Text('Khám phá thêm',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF183D34)))),
            Text('${list.length} mục', style: const TextStyle(fontSize: 12, color: Color(0xFF6F8F83)))]),
          const SizedBox(height: 12),
          if (list.isEmpty) _empty() else
            ...List.generate(list.length, (index) {
              final item = list[index];
              if (featured?.id == item.id && controller.selectedType == 'all') return const SizedBox.shrink();
              final content = Padding(padding: const EdgeInsets.only(bottom: 12), child: MoodActivityCard(
                activity: item, isFavorite: controller.isFavorite(item),
                onFavorite: () => controller.toggleFavorite(item),
                onOpen: () => _openDetail(item)));
              if (MediaQuery.disableAnimationsOf(context)) return content;
              return TweenAnimationBuilder<double>(key: ValueKey(item.id),
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 370 + index * 70),
                curve: Curves.easeOutCubic,
                builder: (_, value, child) => Opacity(opacity: value,
                  child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child)),
                child: content);
            }),
        ]),
    );
  }

  Widget _empty() => Padding(padding: const EdgeInsets.all(32), child: Column(children: [
    const Icon(Icons.sentiment_neutral_rounded, size: 44, color: green),
    const SizedBox(height: 10),
    const Text('Chưa có hoạt động trong nhóm này'),
    const SizedBox(height: 12),
    TextButton(onPressed: () => controller.setType('all'), child: const Text('Xem tất cả')),
  ]));



  
  Widget _error() => Center(child: Padding(padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off_rounded, size: 55, color: green),
      const SizedBox(height: 14),
      const Text('Chưa tải được ý tưởng', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text(controller.errorMessage ?? 'Hãy kiểm tra kết nối.', textAlign: TextAlign.center),
      const SizedBox(height: 18),
      FilledButton.icon(onPressed: controller.load, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
    ])));
  Future<void> _openDetail(ActivityModel activity) async {
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ActivityDetailPage(
      activity: activity, isFavorite: controller.isFavorite(activity),
      onFavoriteChanged: (value) {
        if (controller.isFavorite(activity) != value) controller.toggleFavorite(activity);
      })));
  }
}
