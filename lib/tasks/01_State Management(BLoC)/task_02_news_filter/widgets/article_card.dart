import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article_model.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;

  const ArticleCard({super.key, required this.article});

  static const orange = Color(0xFFF26B0A);

  // dd/MM/yyyy.
  // api có thể thiếu ngày nên cần kiểm tra null
  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa rõ ngày đăng';

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');

    return '$day/$month/${local.year}';
  }


  Future<void> _openArticle(BuildContext context) async {
    final uri = Uri.tryParse(article.url);

    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link bài viết không hợp lệ')),
      );
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không mở được bài viết')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở trình duyệt')),
        );
      }
    }
  }

  // icon thay thế nếu k có bài viết
  Widget _noImage() {
    return Container(
      color: const Color(0xFFFFEEDC),
      child: const Center(
        child: Icon(
          Icons.newspaper_rounded,
          size: 36,
          color: orange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = article.imageUrl.startsWith('https://') ||
        article.imageUrl.startsWith('http://');

    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2E8DF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _openArticle(context),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CachedNetworkImage tải ảnh và hỗ trợ cache ảnh.
                    // Giữ kích thước cố định để các card đều nhau.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 108,
                        height: 125,
                        child: hasImage
                            ? CachedNetworkImage(
                                imageUrl: article.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => _noImage(),
                                errorWidget: (_, _, _) => _noImage(),
                              )
                            : _noImage(),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Expanded giúp tiêu đề dài không tràn ra ngoài card.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.source.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            article.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF292929),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article.description.isEmpty
                                ? 'Nhấn để đọc bài viết đầy đủ.'
                                : article.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: Color(0xFF898989),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1EAE4)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 15,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(article.publishedAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Đọc bài viết',
                      style: TextStyle(
                        color: orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}