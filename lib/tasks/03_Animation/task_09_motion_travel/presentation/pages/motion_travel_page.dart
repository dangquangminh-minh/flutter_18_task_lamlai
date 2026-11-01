

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/motion_travel_repository.dart';
import '../controllers/motion_travel_controller.dart';
import '../widgets/destination_card.dart';
import '../widgets/motion_travel_state_views.dart';

class MotionTravelPage extends StatefulWidget {
  const MotionTravelPage({super.key, required this.repository});
  final MotionTravelRepository repository;
  @override
  State<MotionTravelPage> createState() => _MotionTravelPageState();
}
class _MotionTravelPageState extends State<MotionTravelPage> {
  late final MotionTravelController controller;
  final searchController = TextEditingController();
  static const red = Color(0xFFB83242);
  static const ink = Color(0xFF272F3B);
  @override
  void initState() {
    super.initState();
    controller = MotionTravelController(repository: widget.repository)..load();
  }
  @override
  void dispose() { searchController.dispose(); controller.dispose(); super.dispose(); }
  @override

  Widget build(BuildContext context) {

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(animation: controller, builder: (context, _) => Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(backgroundColor: const Color(0xFFF5F7FB), surfaceTintColor: Colors.transparent,
        title: const Row(children: [
          Icon(Icons.public_rounded, color: red), SizedBox(width: 9),
          Text('Motion Travel', style: TextStyle(color: ink, fontWeight: FontWeight.w900)),
        ])),
      body: RefreshIndicator(color: red, onRefresh: controller.refresh,
        child: ListView(physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(17, 8, 17, 32),
          children: [

            _header(), const SizedBox(height: 18),
            if (controller.fromCache) ...[_offlineNotice(), const SizedBox(height: 14)],
            _search(), const SizedBox(height: 15),
            _regions(), const SizedBox(height: 18),
            _body(reduceMotion),
          ])),
    ));
  }
  Widget _header() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),
      gradient: const LinearGradient(colors: [Color(0xFF28374D), Color(0xFF516B88)])),
    child: Stack(children: [
      Positioned(right: -15, top: -12, child: Icon(Icons.explore_outlined, size: 122,
        color: Colors.white.withValues(alpha: .12))),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('DISCOVER / EXPLORE', style: TextStyle(fontSize: 10,
          fontWeight: FontWeight.w800, letterSpacing: 1.8, color: Color(0xFFA3DAD6))),
        const SizedBox(height: 10),
        const Text('Thế giới đang\nchờ bạn khám phá.', style: TextStyle(
          color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900, height: 1.16)),
        const SizedBox(height: 10),
        const Text('Quốc gia • Hình ảnh • Thời tiết',
          style: TextStyle(color: Color(0xFFDDE9F5), fontSize: 12)),
        const SizedBox(height: 16),


        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(12)),

          child: Text('${controller.countries.length} điểm đến trong bộ sưu tập',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
      ]),
    ]),
  );
  Widget _offlineNotice() {
    final time = controller.cachedAt;
    final updated = time == null ? 'chưa rõ thời điểm lưu'
      : '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
        color: const Color(0xFFFFF0DE), border: Border.all(color: const Color(0xFFF9DFBD))),
      child: Row(children: [const Icon(Icons.cloud_off_rounded, color: Color(0xFFA66529)),
        const SizedBox(width: 10), Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Đang hiển thị bản đã lưu', style: TextStyle(fontSize: 13,
              fontWeight: FontWeight.w900, color: Color(0xFF80511F))),
            Text('Cập nhật: $updated. Kéo xuống để thử tải lại.', style: const TextStyle(
              fontSize: 11, color: Color(0xFFA06A36))),
          ]))]));
  }
  Widget _search() => TextField(controller: searchController,
    onChanged: (value) {
      controller.setSearch(value);
      if (value.trim().isNotEmpty) controller.hydrateVisibleHeroImages();
    },
    textInputAction: TextInputAction.search,
    onSubmitted: (_) => controller.hydrateVisibleHeroImages(),
    decoration: InputDecoration(hintText: 'Quốc gia, thủ đô, điểm đến...',
      prefixIcon: const Icon(Icons.search_rounded, color: red),
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none)));
  Widget _regions() => SizedBox(height: 42,
    child: ListView.separated(scrollDirection: Axis.horizontal,
      itemCount: controller.regions.length,
      separatorBuilder: (_, __) => const SizedBox(width: 7),
      itemBuilder: (_, i) {
        final entry = controller.regions.entries.elementAt(i);
        final selected = controller.selectedRegion == entry.key;
        return ChoiceChip(showCheckmark: false, selected: selected,
          label: Text(entry.value), side: BorderSide.none,
          backgroundColor: Colors.white, selectedColor: red,
          labelStyle: TextStyle(color: selected ? Colors.white : ink, fontWeight: FontWeight.w700),
          onSelected: (_) => controller.setRegion(entry.key));
      }));
  Widget _body(bool reduceMotion) {
    if (controller.status == MotionTravelStatus.initial ||
        controller.status == MotionTravelStatus.loading) {
      return const MotionTravelLoadingView();
    }
    if (controller.status == MotionTravelStatus.error) {
      return MotionTravelErrorView(message: controller.errorMessage ?? 'Không thể tải dữ liệu.',
        onRetry: controller.load);
    }
    final countries = controller.filteredCountries;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Expanded(child: Text('Điểm đến đề xuất',
        style: TextStyle(color: ink, fontSize: 19, fontWeight: FontWeight.w900))),
        Text('${countries.length} kết quả', style: const TextStyle(
          color: Color(0xFF8190A0), fontSize: 12))]),
      const SizedBox(height: 13),

      PageTransitionSwitcher(duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 400),
        transitionBuilder: (child, primary, secondary) => SharedAxisTransition(
          animation: primary, secondaryAnimation: secondary,
          transitionType: SharedAxisTransitionType.horizontal, child: child),
        child: Column(key: ValueKey('${controller.selectedRegion}_${controller.searchQuery}'),
          children: countries.isEmpty
          ? [_empty()]
          : [for (final country in countries)
              Padding(padding: const EdgeInsets.only(bottom: 13),
                child: DestinationCard(country: country, heroUrl: controller.heroFor(country),
                  repository: widget.repository, reduceMotion: reduceMotion))],
        )),
    ]);
  }
  Widget _empty() => Container(width: double.infinity, padding: const EdgeInsets.all(35),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: const Column(children: [Icon(Icons.travel_explore_outlined, color: red, size: 44),
      SizedBox(height: 10), Text('Không tìm thấy điểm đến phù hợp', textAlign: TextAlign.center),
    ]));
}
