import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/visual_news_repository.dart';

import '../../domain/models/visual_article.dart';
import '../news_palette.dart';


class VisualArticleDetailPage extends StatefulWidget {
  const VisualArticleDetailPage({super.key, required this.article, required this.repository});
  final VisualArticle article;
  final VisualNewsRepository repository;

  @override
  State<VisualArticleDetailPage> createState() => _VisualArticleDetailPageState();
}

class _VisualArticleDetailPageState extends State<VisualArticleDetailPage> {
  late VisualArticle article;

  @override
  //nhận bài đang chọn từ trang ds
  void initState() {
    super.initState();
    article = widget.article;
  }

  // lưu bookmark vào sql rồi update icon tim khi thao tác t.công
  Future<void> _toggle() async {
    final saved = await widget.repository.toggleBookmark(article);
    if (!mounted) return;
    setState(() => article = article.copyWith(isBookmarked: saved));
  }


  Future<void> _open(String url) async {

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở  liên kết trên thiết bị.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: newsNight,
    appBar: AppBar(

      backgroundColor: newsNight, foregroundColor: newsWhite,
      title: const Text('Chi tiết bản tin', style: TextStyle(fontWeight: FontWeight.w900)),
      actions: [IconButton(onPressed: _toggle,
        tooltip: article.isBookmarked ? 'Bỏ lưu' : 'Lưu bài',

        icon: Icon(article.isBookmarked
            ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: newsGold))],
    ),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 30), children: [

      if (article.imageUrl.isNotEmpty)
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: CachedNetworkImage(imageUrl: article.imageUrl,
              width: double.infinity, height: 250, fit: BoxFit.cover,
              errorWidget: (_, _, _) => Container(
                  height: 250, color: newsCard,
                  child: const Icon(Icons.image_outlined, color: newsGold, size: 60))),
        ),

      if (article.imageAuthor != null) ...[
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _open(article.imageAuthorUrl ?? 'https://unsplash.com'),
          icon: const Icon(Icons.photo_camera_outlined, size: 15),
          label: Text('Ảnh: ${article.imageAuthor} / Unsplash',
              style: const TextStyle(fontSize: 11)),
          style: TextButton.styleFrom(foregroundColor: newsGold),
        ),
      ],
      const SizedBox(height: 21),
      Text(article.topic.toUpperCase(), style: const TextStyle(
          color: newsGold, fontSize: 11, letterSpacing: 1.5,
          fontWeight: FontWeight.w900)),
      const SizedBox(height: 11),
      Text(article.title, style: const TextStyle(
          color: newsWhite, fontSize: 26, height: 1.25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 13),
      Text('${article.source} · ${article.publishedAt}', style: const TextStyle(
          color: newsMuted, fontSize: 12)),
      const SizedBox(height: 19),
      const Divider(color: Color(0xFF405063)),
      const SizedBox(height: 18),
      Text(article.description.isEmpty
          ? 'NewsAPI không cung cấp mô tả cho bài viết này.'
          : article.description,
          style: const TextStyle(color: newsWhite, fontSize: 16, height: 1.65)),
      const SizedBox(height: 18),

      if (article.cachedAt != null)
        const Text('Nội dung giới thiệu đã lưu trong SQLite. Ảnh và bài gốc có thể cần mạng.',
            style: TextStyle(color: newsMuted, fontSize: 11)),
      const SizedBox(height: 27),
      FilledButton.icon(
        onPressed: article.url.isEmpty ? null : () => _open(article.url),
        icon: const Icon(Icons.open_in_new_rounded),
        label: const Text('Đọc bài gốc'),
        style: FilledButton.styleFrom(
          backgroundColor: newsGold, foregroundColor: newsNight,
          minimumSize: const Size.fromHeight(52),
        ),
      ),
    ]),
  );
}
