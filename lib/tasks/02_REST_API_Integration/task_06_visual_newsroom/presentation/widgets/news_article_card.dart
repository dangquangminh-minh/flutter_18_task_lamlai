import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/models/visual_article.dart';
import '../news_palette.dart';


class NewsArticleCard extends StatelessWidget {
  const NewsArticleCard({super.key, required this.article,
    required this.onTap, required this.onBookmark, this.featured = false});

  final VisualArticle article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final bool featured;


  Widget _photo(double height) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      width: double.infinity, height: height,
      child: article.imageUrl.isEmpty
          ? Container(color: newsCard, child: const Icon(
              Icons.auto_stories_rounded, color: newsGold, size: 55))
          : CachedNetworkImage(
              imageUrl: article.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: newsCard),

              errorWidget: (_, _, _) => Container(color: newsCard,
                  child: const Icon(Icons.broken_image_outlined, color: newsGold)),
            ),
    ),
  );

  @override
  // h.thị ảnh, tiêu đề, nguồn, ngày và nút bookmark mà không trực tiếp gọi sqlite
  Widget build(BuildContext context) => Material(
    color: newsCard,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _photo(featured ? 210 : 158),
          const SizedBox(height: 13),
          Row(children: [
            Expanded(child: Text(article.source.toUpperCase(), maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, letterSpacing: 1.3,
                    color: newsGold, fontWeight: FontWeight.w900))),
            IconButton(
              onPressed: onBookmark,
              constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
              padding: EdgeInsets.zero,
              tooltip: article.isBookmarked ? 'Bỏ lưu' : 'Lưu bài',
              icon: Icon(article.isBookmarked
                  ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: article.isBookmarked ? newsGold : newsMuted),
            ),
          ]),
          const SizedBox(height: 5),
          Text(article.title, maxLines: featured ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: newsWhite, fontSize: featured ? 20 : 16,
                  height: 1.3, fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
          if (article.description.isNotEmpty)
            Text(article.description, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: newsMuted, height: 1.5)),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.schedule_outlined, size: 13, color: newsMuted),
            const SizedBox(width: 5),
            Expanded(child: Text(article.publishedAt.length >= 10
                ? article.publishedAt.substring(0, 10)
                : article.publishedAt,
                style: const TextStyle(fontSize: 11, color: newsMuted))),
            const Icon(Icons.arrow_outward_rounded, size: 18, color: newsGold),
          ]),

          if (article.imageAuthor != null) ...[
            const SizedBox(height: 6),
            Text('Ảnh: ${article.imageAuthor} / Unsplash',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: newsMuted)),
          ],
        ]),
      ),
    ),
  );
}
