

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../data/repositories/photo_repository.dart';
import '../../domain/models/pixabay_photo.dart';
import '../controllers/photo_gallery_controller.dart';
import '../widgets/photo_grid_card.dart';

import '../widgets/photo_state_views.dart';
import 'photo_detail_page.dart';

class PhotoGalleryPage extends StatefulWidget {
  const PhotoGalleryPage({super.key, required this.repository});
  final PhotoRepository repository;
  @override
  State<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}
class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  late final PhotoGalleryController controller;
  final TextEditingController searchController = TextEditingController(text: 'nature');
  final ScrollController scrollController = ScrollController();
  static const orange = Color(0xFFBB5837);
  static const ink = Color(0xFF342D2A);
  static const categories = <String, (String, IconData)>{
    'nature': ('Thiên nhiên', Icons.forest_rounded),
    'architecture': ('Kiến trúc', Icons.apartment_rounded),
    'travel': ('Du lịch', Icons.flight_rounded),

    'animals': ('Động vật', Icons.pets_rounded),

    'people': ('Con người', Icons.groups_rounded),
  };

  @override
  void initState() {
    super.initState();
    controller = PhotoGalleryController(repository: widget.repository)..init();

    scrollController.addListener(_loadWhenNearBottom);
  }
  // cuộn xuống để tải,controller chặn request trùng
  void _loadWhenNearBottom() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.extentAfter < 480) controller.loadMore();
  }

  @override
  void dispose() {
    scrollController.removeListener(_loadWhenNearBottom);
    scrollController.dispose();
    searchController.dispose();


    controller.dispose();
    super.dispose();
  }
  void _submitSearch(String value) {
    FocusScope.of(context).unfocus();
    controller.search(value);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller, builder: (context, _) => Scaffold(
      backgroundColor: const Color(0xFFFAF6F1),
      appBar: AppBar(backgroundColor: const Color(0xFFFAF6F1), surfaceTintColor: Colors.transparent,
        title: const Row(children: [
          Icon(Icons.photo_library_outlined, color: orange), SizedBox(width: 10),
          Text('Photo Stories', style: TextStyle(fontWeight: FontWeight.w900, color: ink)),
        ])),
      body: RefreshIndicator(color: orange, onRefresh: controller.refresh,
        child: ListView(controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 32), children: [
            _masthead(),
            const SizedBox(height: 20),
            _searchBar(),
            const SizedBox(height: 15),
            _chips(),
            const SizedBox(height: 20),
            _results(),
          ])),
    ));

  Widget _masthead() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(26),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF803E39), Color(0xFFDA8862)])),
    child: Stack(children: [
      Positioned(right: -8, top: 0, child: Icon(Icons.camera_outlined,
        size: 115, color: Colors.white.withValues(alpha: .11))),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('COLLECT THE MOMENTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
          letterSpacing: 2, color: Color(0xFFFFD9C5))),
        SizedBox(height: 9),
        
        Text('Mỗi tấm ảnh\nmột câu chuyện.', style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28, height: 1.17)),
        SizedBox(height: 10),
        Text('Khám phá, chạm, rồi kéo ảnh xuống để quay lại.',
          style: TextStyle(color: Color(0xFFFFEAE0), fontSize: 12)),
      ]),
    ]),
  );
  Widget _searchBar() => Material(color: Colors.white,
    elevation: 0, borderRadius: BorderRadius.circular(17),
    child: TextField(controller: searchController,
      textInputAction: TextInputAction.search, onSubmitted: _submitSearch,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(hintText: 'Tìm hình ảnh theo cảm hứng...',
        prefixIcon: const Icon(Icons.search_rounded, color: orange),
        suffixIcon: searchController.text.isEmpty ? null : IconButton(
          tooltip: 'Xóa tìm kiếm', onPressed: () => setState(searchController.clear),
          icon: const Icon(Icons.close_rounded, size: 19)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFECE1D8))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFECE1D8))),
      )));
  Widget _chips() => SizedBox(height: 43,
    child: ListView.separated(scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(width: 7),
      itemBuilder: (_, i) {
        final entry = categories.entries.elementAt(i);
        final selected = controller.selectedCategory == entry.key;
        return ChoiceChip(showCheckmark: false,
          avatar: Icon(entry.value.$2, size: 16,
            color: selected ? Colors.white : orange),
          label: Text(entry.value.$1), selected: selected,
          side: BorderSide.none, backgroundColor: Colors.white,
          selectedColor: orange,
          labelStyle: TextStyle(fontWeight: FontWeight.w700,
            color: selected ? Colors.white : ink),
          onSelected: (_) {
            searchController.text = entry.key;
            controller.changeCategory(entry.key);
          });
      }));

  Widget _results() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      const Expanded(child: Text('Khung hình nổi bật', style: TextStyle(
        fontWeight: FontWeight.w900, color: ink, fontSize: 19))),
      if (controller.status == PhotoGalleryStatus.success)
        Text('${controller.totalHits} ảnh · Trang ${controller.page}',
          style: const TextStyle(color: Color(0xFF988B84), fontSize: 11)),
    ]),
    const SizedBox(height: 13),
    // Các trạng thái UI đều được thể hiện trực tiếp, không chỉ log ra console.
    if (controller.status == PhotoGalleryStatus.loading ||
        controller.status == PhotoGalleryStatus.initial)
      const PhotoLoadingView()
    else if (controller.status == PhotoGalleryStatus.error)
      PhotoErrorView(message: controller.errorMessage ?? 'Không tải được ảnh',
        onRetry: controller.refresh)
    else if (controller.photos.isEmpty)
      PhotoEmptyView(query: controller.query)
    else ...[
      AnimatedSwitcher(duration: const Duration(milliseconds: 380),
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 680;
          return MasonryGridView.count(
            key: ValueKey(controller.transitionVersion),
            crossAxisCount: wide ? 3 : 2,
            mainAxisSpacing: 12, crossAxisSpacing: 12,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.photos.length,
            itemBuilder: (_, i) {
              final photo = controller.photos[i];
              final card = PhotoGridCard(photo: photo,
                spotlight: i == 0, onTap: () => _openDetail(photo));
              if (MediaQuery.disableAnimationsOf(context)) return card;
              return card.animate(delay: Duration(milliseconds: (i % 12) * 50))
                .fadeIn(duration: 350.ms)
                .slideY(begin: .08, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
            },
          );
        })),
      if (controller.isLoadingMore)
        const Padding(padding: EdgeInsets.all(22), child: Center(
          child: CircularProgressIndicator(color: orange)))
      else if (controller.loadMoreError != null)
        _loadMoreRetry()
      else if (controller.hasMore)
        Padding(padding: const EdgeInsets.symmetric(vertical: 15),
          child: Center(child: OutlinedButton.icon(
            onPressed: controller.loadMore,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tải thêm ảnh'))))
      else
        Padding(padding: const EdgeInsets.only(top: 24),
          child: Center(child: Text('Đã xem ${controller.photos.length} ảnh · Hết kết quả',
            style: const TextStyle(color: Color(0xFF988B84))))),
    ],
  ]);
  Widget _loadMoreRetry() => Container(
    margin: const EdgeInsets.only(top: 18), padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: const Color(0xFFFCE7DD), borderRadius: BorderRadius.circular(13)),
    child: Row(children: [
      const Icon(Icons.wifi_off_rounded, color: orange), const SizedBox(width: 8),
      const Expanded(child: Text('Không tải được trang tiếp theo.')),
      TextButton(onPressed: controller.retryLoadMore, child: const Text('Thử lại')),
    ]));
  void _openDetail(PixabayPhoto photo) => Navigator.push(context,
    MaterialPageRoute<void>(builder: (_) => PhotoDetailPage(photo: photo)));
}
