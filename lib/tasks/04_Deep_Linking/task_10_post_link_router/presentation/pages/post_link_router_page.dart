

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/post_repository.dart';
import '../../domain/models/post_model.dart';
import '../../services/post_deep_link_parser.dart';



class PostLinkRouterPage extends StatefulWidget {
  const PostLinkRouterPage({super.key, required this.repository});
  final PostRepository repository;

  @override
  State<PostLinkRouterPage> createState() => _PostLinkRouterPageState();
}

class _PostLinkRouterPageState extends State<PostLinkRouterPage> {
  static const ink = Color(0xFF132D33);
  static const mint = Color(0xFF0E8D7F);
  static const bg = Color(0xFFF4F7F5);
  final input = TextEditingController(text: 'myapp://post/12');
  late Future<List<PostModel>> suggestions;

  @override
  void initState() {
    super.initState();
    suggestions = widget.repository.getSamplePosts();
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  // trước khi đổi trang cần gọi parser
  void _open([String? value]) {
    final raw = (value ?? input.text).trim();
    final id = PostDeepLinkParser.parse(raw);
    if (id == null) {
      context.push(Uri(path: '/invalid-link', queryParameters: {
        'uri': raw,
        'reason': 'Đường dẫn cần có dạng myapp://post/{id} với id > 0.',
      }).toString());
      return;
    }
    context.push('/post/$id?source=manual');
  }



  void _reload() => setState(() => suggestions = widget.repository.getSamplePosts());

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: input.text.trim()));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép liên kết')),);
  }

  // card gợi ý mở link vs liên kết người dùng dán

  Widget _sample(PostModel post) => InkWell(
    onTap: () => _open(PostDeepLinkParser.buildPostLink(post.id)),
    borderRadius: BorderRadius.circular(19),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19)),
      child: Row(children: [
        Container(width: 47, height: 50, alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFFE3F6EF), borderRadius: BorderRadius.circular(14)),
          child: Text('${post.id}', style: const TextStyle(fontSize: 19, color: mint, fontWeight: FontWeight.w800))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: ink)),
          const SizedBox(height: 6),
          Text('myapp://post/${post.id}', style: const TextStyle(color: mint, fontSize: 11)),
        ])),
        const Icon(Icons.north_east_rounded, color: mint),
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: bg,
    appBar: AppBar(title: const Text('Post Link Studio', style: TextStyle(fontWeight: FontWeight.w800)),
      backgroundColor: bg, surfaceTintColor: Colors.transparent, foregroundColor: ink),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(17), children: [
      Container(padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(28)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.hub_outlined, color: Color(0xFF64DBC2)), SizedBox(width: 8),
            Text('DEEP LINK • BÀI 10', style: TextStyle(color: Color(0xFF9FDDCE), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2))]),
          const SizedBox(height: 16),
          const Text('Một đường dẫn.\nĐúng bài viết.', style: TextStyle(color: Colors.white, fontSize: 29, height: 1.16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 9),
          const Text('Dán URI để kiểm tra parser và mở thẳng trang chi tiết.', style: TextStyle(color: Color(0xFFCCE3DD), height: 1.5, fontSize: 13)),
          const SizedBox(height: 20),


          TextField(controller: input, keyboardType: TextInputType.url,
            style: const TextStyle(fontSize: 13),
            onSubmitted: (_) => _open(),
            decoration: InputDecoration(hintText: 'myapp://post/12', filled: true, fillColor: Colors.white,
              prefixIcon: const Icon(Icons.link_rounded, color: mint),
              suffixIcon: IconButton(onPressed: _copy, icon: const Icon(Icons.copy_rounded)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 49, child: FilledButton.icon(
            onPressed: () => _open(),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF65DDC4), foregroundColor: ink),
            icon: const Icon(Icons.arrow_forward_rounded), label: const Text('Kiểm tra & mở bài viết'))),
        ])),
      const SizedBox(height: 23),
      const Row(children: [Icon(Icons.auto_awesome_rounded, color: mint, size: 20), SizedBox(width: 9),
        Text('Liên kết thử nhanh', style: TextStyle(fontSize: 18, color: ink, fontWeight: FontWeight.w800))]),
      const SizedBox(height: 11),
      Wrap(spacing: 8, children: [12, 15, 24, -1].map((id) => ActionChip(
        label: Text(id < 0 ? 'Link lỗi' : 'Post #$id'),
        onPressed: () { final uri = id < 0 ? 'myapp://post/abc' : PostDeepLinkParser.buildPostLink(id);
          input.text = uri; _open(uri); },


        backgroundColor: Colors.white, side: const BorderSide(color: Color(0xFFDCE8E3)),
      )).toList()),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Bài viết nổi bật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
        TextButton.icon(onPressed: _reload, icon: const Icon(Icons.refresh_rounded, size: 17), label: const Text('Tải lại')),
      ]),


      FutureBuilder<List<PostModel>>(future: suggestions, builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(padding: EdgeInsets.all(35), child: Center(child: CircularProgressIndicator(color: mint)));
        }
        if (snapshot.hasError) return _notice('Không tải được bài gợi ý', 'Kiểm tra mạng rồi bấm Tải lại.');
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) return _notice('Chưa có bài viết', 'Dùng ô URI phía trên để thử một bài khác.');
        return Column(children: posts.map(_sample).toList());
      }),
    ])),
  );

  Widget _notice(String title, String subtitle) => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(children: [const Icon(Icons.wifi_off_rounded, color: mint, size: 35),
      const SizedBox(height: 9), Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(subtitle, textAlign: TextAlign.center),
      TextButton(onPressed: _reload, child: const Text('Thử lại'))]),
  );
}
