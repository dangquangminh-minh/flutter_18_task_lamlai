

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


class PhotoLoadingView extends StatelessWidget {
  const PhotoLoadingView({super.key});
  @override
  Widget build(BuildContext context) {
    const heights = [230.0, 182.0, 200.0, 260.0, 225.0, 170.0];
    return MasonryGridView.count(
      crossAxisCount: 2, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12, crossAxisSpacing: 12, itemCount: heights.length,
      itemBuilder: (_, index) {
        final skeleton = Container(height: heights[index],
          decoration: BoxDecoration(color: const Color(0xFFEFE2D9),
            borderRadius: BorderRadius.circular(18)));
        if (MediaQuery.disableAnimationsOf(context)) return skeleton;
        return skeleton.animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 1250.ms, color: Colors.white70);
      },
    );
  }
}
class PhotoErrorView extends StatelessWidget {
  const PhotoErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(children: [
      const Icon(Icons.cloud_off_rounded, size: 50, color: Color(0xFFBB5837)),
      const SizedBox(height: 13),
      const Text('Chưa tải được ảnh', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF776F6D))),
      const SizedBox(height: 15),
      FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded),
        label: const Text('Thử lại')),
    ]));
}
class PhotoEmptyView extends StatelessWidget {
  const PhotoEmptyView({super.key, required this.query});
  final String query;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(children: [
      const Icon(Icons.image_search_rounded, size: 48, color: Color(0xFFBB5837)),
      const SizedBox(height: 10),
      
      const Text('Chưa tìm thấy bức ảnh phù hợp', textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 7),
      Text('Từ khóa: "$query". Thử tìm một chủ đề khác nhé.',
        textAlign: TextAlign.center),
    ]));
}
