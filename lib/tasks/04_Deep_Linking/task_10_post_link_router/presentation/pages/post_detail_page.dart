

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/repositories/post_repository.dart';
import '../../domain/models/post_model.dart';
import '../../services/post_deep_link_parser.dart';
import '../controllers/post_detail_controller.dart';
import 'post_invalid_link_page.dart';

// chi tiết lấy id từ route
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.repository, required this.postId, this.openedFromDeepLink = false});
  final PostRepository repository;
  final int postId;
  final bool openedFromDeepLink;
  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  static const ink = Color(0xFF132D33);
  static const mint = Color(0xFF0E8D7F);
  late final PostDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = PostDetailController(repository: widget.repository, postId: widget.postId)..load();
  }

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  Future<void> _share(PostModel post) async {
    await SharePlus.instance.share(ShareParams(text: '${post.title}\n${PostDeepLinkParser.buildPostLink(post.id)}'));
  }

  // copy custom uri để test mở bằng adb
  Future<void> _copy(int id) async {
    await Clipboard.setData(ClipboardData(text: PostDeepLinkParser.buildPostLink(id)));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép Deep Link')));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: controller, builder: (context, _) {
    if (controller.status == PostDetailStatus.notFound) {
      return PostInvalidLinkPage(uri: PostDeepLinkParser.buildPostLink(widget.postId),
        message: controller.errorMessage ?? 'Bài viết không tồn tại.', onRetry: controller.load);
    }
    final post = controller.post;
    return Scaffold(backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(backgroundColor: const Color(0xFFF4F7F5), surfaceTintColor: Colors.transparent,
        title: const Text('Reading room', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [if (post != null) IconButton(onPressed: () => _share(post), icon: const Icon(Icons.ios_share_rounded))]),


      body: controller.status == PostDetailStatus.loading
        ? const Center(child: CircularProgressIndicator(color: mint))
        : controller.status == PostDetailStatus.error
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min,
              children: [const Icon(Icons.cloud_off_rounded, size: 46, color: mint), const SizedBox(height: 12),
                Text(controller.errorMessage ?? 'Có lỗi khi tải bài viết', textAlign: TextAlign.center),

                const SizedBox(height: 12), FilledButton(onPressed: controller.load, child: const Text('Thử lại'))])))
          : post == null ? const Center(child: Text('Không có dữ liệu')) :
            ListView(padding: const EdgeInsets.all(17), children: [
              Container(padding: const EdgeInsets.all(25), decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(27)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.menu_book_rounded, color: Color(0xFF77E5CF)), const SizedBox(width: 9),
                    Text('ARTICLE / ${post.id.toString().padLeft(3, '0')}', style: const TextStyle(color: Color(0xFF9FE9D6), fontSize: 12, letterSpacing: 1.2))]),
                  const SizedBox(height: 20),
                  Text(post.title, style: const TextStyle(color: Colors.white, fontSize: 29, height: 1.2, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 17),
                  
                  Text('Người viết #${post.userId}  •  ${widget.openedFromDeepLink ? 'Mở từ Deep Link' : 'Xem trong ứng dụng'}',
                    style: const TextStyle(color: Color(0xFFBAD8D2), fontSize: 12)),
                ])),
              const SizedBox(height: 18),
              Container(padding: const EdgeInsets.all(23), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('NỘI DUNG BÀI VIẾT', style: TextStyle(fontSize: 11, color: mint, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 18), Text(post.body, style: const TextStyle(fontSize: 17, height: 1.8, color: ink)),
                ])),
              const SizedBox(height: 18),
              Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0xFFE2F4EE), borderRadius: BorderRadius.circular(18)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('ĐƯỜNG DẪN CỦA BÀI', style: TextStyle(fontSize: 11, color: mint, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8), SelectableText(PostDeepLinkParser.buildPostLink(post.id), style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 13), Row(children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () => _copy(post.id), icon: const Icon(Icons.copy_rounded), label: const Text('Sao chép'))),
                    const SizedBox(width: 9), Expanded(child: FilledButton.icon(onPressed: () => _share(post),
                      style: FilledButton.styleFrom(backgroundColor: ink), icon: const Icon(Icons.share_rounded), label: const Text('Chia sẻ'))),
                  ]),
                ])),
            ]),
    );
  });
}
