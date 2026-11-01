import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/visual_news_repository.dart';
import '../controllers/visual_news_controller.dart';
import '../news_palette.dart';
import '../widgets/news_article_card.dart';


import 'offline_bookmarks_page.dart';
import 'visual_article_detail_page.dart';


class VisualNewsPage extends StatefulWidget {
  const VisualNewsPage({super.key, required this.repository});
  final VisualNewsRepository repository;

  @override
  State<VisualNewsPage> createState() => _VisualNewsPageState();
}

class _VisualNewsPageState extends State<VisualNewsPage> {
  late final VisualNewsController controller;
  final scrollController = ScrollController();

  @override
  // tạo controller
  void initState() {
    super.initState();
    controller = VisualNewsController(repository: widget.repository);
    controller.loadInitial();
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;
      //  còn dưới 300px trước cuối danh sách thì y.cầu tải trang t.theo
      if (scrollController.position.extentAfter < 300) controller.loadMore();
    });
  }

  @override
  // giải phóng scrollController và newsController
  void dispose() {
    scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  // mở trang chi tiết
  Future<void> _openArticle(int index) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => VisualArticleDetailPage(
        article: controller.articles[index], repository: widget.repository,
      ),
    ));

    if (!mounted) return;
    await controller.refresh();
  }

  // banner tạp chí
  Widget _header() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF243A51), Color(0xFF101B2B)]),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFF3C5063)),
    ),
    child: const Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('VISUAL NEWSROOM', style: TextStyle(color: newsGold,
            letterSpacing: 1.6, fontSize: 10, fontWeight: FontWeight.w900)),
        SizedBox(height: 10),

        Text('Đọc tin bằng\nmột góc nhìn mới.', style: TextStyle(
            color: newsWhite, fontSize: 24, fontWeight: FontWeight.w900,
            height: 1.2)),
        SizedBox(height: 10),

        Text('Bản tin hôm nay, lưu lại để đọc sau.', style: TextStyle(
            color: newsMuted, fontSize: 12)),
      ])),
      Icon(Icons.auto_stories_outlined, size: 53, color: newsGold),
    ]),
  );

  // chip 
  Widget _topics() => SizedBox(
    height: 42,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: controller.topics.length,
      separatorBuilder: (_, _) => const SizedBox(width: 9),
      itemBuilder: (context, index) {
        final item = controller.topics.entries.elementAt(index);
        final selected = item.key == controller.topic;
        return ChoiceChip(
          label: Text(item.value), selected: selected,
          onSelected: (_) => controller.changeTopic(item.key),
          backgroundColor: newsCard,
          selectedColor: newsGold,
          side: BorderSide.none,
          labelStyle: TextStyle(color: selected ? newsNight : newsWhite,
              fontSize: 12, fontWeight: FontWeight.w700),
        );
      },
    ),
  );

  // p.biệt dữ liệu sqlite) với dl đang xem tr.tuyến
  Widget _status() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFF28394A),
        borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(controller.isOffline ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
          size: 18, color: newsGold),
      const SizedBox(width: 8),
      Expanded(child: Text(
        controller.isOffline
            ? 'Đang xem tin từ SQLite (dữ liệu có thể cũ)'
            : 'Tin trực tuyến · Có lưu bản sao trên thiết bị',
        style: const TextStyle(color: newsWhite, fontSize: 11),
      )),
    ]),
  );


  Widget _error(String message) => Container(
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(color: newsCard, borderRadius: BorderRadius.circular(20)),
    child: Column(children: [
      const Icon(Icons.wifi_off_rounded, size: 47, color: newsGold),
      const SizedBox(height: 12),
      const Text('Chưa tải được bản tin', style: TextStyle(
          color: newsWhite, fontSize: 17, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center,
          style: const TextStyle(color: newsMuted, height: 1.5)),
      const SizedBox(height: 14),
      FilledButton.icon(
        
        onPressed: controller.refresh,
        icon: const Icon(Icons.refresh_rounded), label: const Text('Thử lại'),
        style: FilledButton.styleFrom(backgroundColor: newsGold,
            foregroundColor: newsNight),
      ),
    ]),
  );

  //xử lý cả loading, error, empty, ds và trạng thái tải thêm
  Widget _articles() {
    // lúc chưa có dl, hiển thị loader
    if (controller.status == NewsroomStatus.loading && controller.articles.isEmpty) {
      return const Padding(padding: EdgeInsets.all(55),
          child: Center(child: CircularProgressIndicator(color: newsGold)));
    }
    if (controller.status == NewsroomStatus.error) {
      return _error(controller.errorMessage ?? 'Không thể kết nối tới NewsAPI.');
    }
    if (controller.articles.isEmpty) {
      return _error('Chưa có tin cho chủ đề này. Hãy chọn chủ đề khác.');
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      if (controller.isOffline) ...[_status(), const SizedBox(height: 15)],
      Text('${controller.articles.length} tin trong chủ đề',
          style: const TextStyle(color: newsWhite, fontSize: 18,
              fontWeight: FontWeight.w900)),
      const SizedBox(height: 14),
      ...List.generate(controller.articles.length, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: NewsArticleCard(
          article: controller.articles[index],
          featured: index == 0,
          onTap: () => _openArticle(index),
          onBookmark: () => controller.toggleBookmark(index),
        ),
      )),

      if (controller.isLoadingMore)
        const Padding(padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator(color: newsGold)))
      else if (controller.loadMoreFailed)
        Center(child: OutlinedButton.icon(
          onPressed: controller.loadMore, icon: const Icon(Icons.refresh),
          label: const Text('Tải trang tiếp theo'),
        ))
      else if (!controller.hasMore)
        const Center(child: Padding(padding: EdgeInsets.all(12),
            child: Text('Đã xem hết tin trong chủ đề.',
                style: TextStyle(color: newsMuted)))),
    ]);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Scaffold(
      backgroundColor: newsNight,

      appBar: AppBar(
        backgroundColor: newsNight, foregroundColor: newsWhite,
        title: const Text('The Daily Frame',
            style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(icon: const Icon(Icons.bookmarks_outlined),
              tooltip: 'Bài đã lưu',
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => OfflineBookmarksPage(repository: widget.repository),
              ))),
          IconButton(icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Làm mới', onPressed: controller.refresh),
        ],
      ),
      // vuốt xuống để làm mới trang 1 và đồng bộ lại cache
      body: RefreshIndicator(
        onRefresh: controller.refresh, color: newsGold,
        child: ListView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 25),
          children: [
            _header(),
            const SizedBox(height: 18),
            _topics(),
            const SizedBox(height: 21),
            _articles(),
            const SizedBox(height: 10),
            Center(child: TextButton(
              onPressed: () => launchUrl(Uri.parse('https://unsplash.com'),
                  mode: LaunchMode.externalApplication),
              child: const Text('Ảnh bổ sung từ Unsplash · ghi nguồn tác giả trong bài',
                  style: TextStyle(color: newsGold, fontSize: 11)),
            )),
          ],
        ),
      ),
    ),
  );
}
