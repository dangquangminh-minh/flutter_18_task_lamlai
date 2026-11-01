import 'package:flutter/material.dart';
import '../../data/repositories/visual_news_repository.dart';
import '../../domain/models/visual_article.dart';
import '../news_palette.dart';
import '../widgets/news_article_card.dart';
import 'visual_article_detail_page.dart';


class OfflineBookmarksPage extends StatefulWidget {
  const OfflineBookmarksPage({super.key, required this.repository});
  final VisualNewsRepository repository;

  @override
  State<OfflineBookmarksPage> createState() => _OfflineBookmarksPageState();
}

class _OfflineBookmarksPageState extends State<OfflineBookmarksPage> {
  final searchController = TextEditingController();
  List<VisualArticle> bookmarks = [];
  bool loading = true;
  String? error;

  @override
  // lần đầu mở tab thì lấyds bookmark từ db
  void initState() {
    super.initState();
    _reload();
  }

  @override
  // g.phóng bộ điều khiển t.kiếm khi rời trang
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // vuốt làm mới hoặc quay lại trang chi tiết
  Future<void> _reload() async {
    try {
      final result = await widget.repository.getBookmarks();
      if (!mounted) return;
      setState(() { bookmarks = result; loading = false; error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = e.toString(); loading = false; });
    }
  }


  List<VisualArticle> get _filtered {
    final q = searchController.text.toLowerCase().trim();
    return bookmarks.where((article) => article.title.toLowerCase().contains(q)).toList();
  }


  Future<void> _remove(VisualArticle article) async {
    await widget.repository.removeBookmark(article.id);
    await _reload();
  }

  @override
  // h.thị l.sử off, thanh tìm, trạng thái rỗng và các thẻ tin
  Widget build(BuildContext context) {
    final results = _filtered;
    return Scaffold(
      backgroundColor: newsNight,
      appBar: AppBar(backgroundColor: newsNight, foregroundColor: newsWhite,
          title: const Text('Thư viện đã lưu',
              style: TextStyle(fontWeight: FontWeight.w900))),
      // Kéo xuống để đọc lại database, không buộc gọi API khi ngoại tuyến.
      body: RefreshIndicator(
        color: newsGold, onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 25),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: newsCard,
                  borderRadius: BorderRadius.circular(24)),
              child: Row(children: [
                const Icon(Icons.bookmarks_rounded, color: newsGold, size: 44),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${bookmarks.length} bài viết đã lưu', style: const TextStyle(
                      color: newsWhite, fontSize: 19, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text('Nội dung và mô tả đã lưu trong SQLite.',


                      style: TextStyle(color: newsMuted, fontSize: 12)),
                ])),
              ]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: newsWhite),
              decoration: InputDecoration(
                hintText: 'Tìm trong bài đã lưu...',
                hintStyle: const TextStyle(color: newsMuted),
                prefixIcon: const Icon(Icons.search, color: newsGold),
                filled: true, fillColor: newsCard,
                border: OutlineInputBorder(borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),

            const SizedBox(height: 18),

            if (loading)

              const Center(child: Padding(padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(color: newsGold)))
            else if (error != null)
              Text('Không đọc được SQLite: $error',
                  style: const TextStyle(color: newsWhite))
            else if (results.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(color: newsCard,
                    borderRadius: BorderRadius.circular(20)),
                child: const Column(children: [
                  Icon(Icons.bookmark_border, color: newsGold, size: 48),
                  SizedBox(height: 12),
                  Text('Chưa có bài viết phù hợp',
                      style: TextStyle(color: newsWhite, fontWeight: FontWeight.bold)),
                  SizedBox(height: 7),
                  Text('Lưu bài từ trang tin để xem lại ở đây.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: newsMuted)),
                ]),
              )
            else ...results.map((article) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Dismissible(
                key: ValueKey(article.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: const Color(0xFF8E3445),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),

                onDismissed: (_) => _remove(article),
                child: NewsArticleCard(
                  article: article,
                  onBookmark: () => _remove(article),
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => VisualArticleDetailPage(
                          article: article, repository: widget.repository),
                    ));
                    await _reload();
                  },
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
