import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../domain/models/task17_models.dart';
import '../controllers/task17_social_controller.dart';
import '../widgets/task17_widgets.dart';


class Task17PostHistoryPage extends StatefulWidget {
  const Task17PostHistoryPage({
    super.key, required this.controller, required this.user, });

  final Task17SocialController controller;
  final User user;

  @override
  State<Task17PostHistoryPage> createState() => _Task17PostHistoryPageState();
}

class _Task17PostHistoryPageState extends State<Task17PostHistoryPage> {
  final searchController = TextEditingController();

  String search = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor: const Color(0xFFF8F6F4), appBar: AppBar( elevation: 0,
        backgroundColor: const Color(0xFFF8F6F4), surfaceTintColor: Colors.transparent,
        foregroundColor: task17Text, title: const Text( 'Lịch sử bài viết', style: TextStyle(
            fontWeight: FontWeight.w800, ), ),
        actions: [
          IconButton( tooltip: 'Làm mới', onPressed: widget.controller.postsLoading
                    ? null
                    : () {
                        widget.controller .loadPosts( widget.user, );
                      },
            icon: const Icon( Icons.refresh_rounded, ), ),
          const SizedBox(width: 6), ], ),
      body: AnimatedBuilder( animation: widget.controller, builder: (context, _) {
          final controller = widget.controller;

          final filtered = controller.searchPosts(search);

          return RefreshIndicator( color: task17Orange, onRefresh: () => controller.loadPosts(
              widget.user, ),
            child: ListView( physics: const AlwaysScrollableScrollPhysics(), padding:
                  const EdgeInsets.fromLTRB(
                18, 10, 18, 40, ),
              children: [
                _headerCard(controller),

                const SizedBox(height: 18),

                _searchField(),

                const SizedBox(height: 18),

                if (controller.postsLoading && controller.posts.isEmpty)
                  _loadingCard()
                else if (controller .postsError != null && controller.posts.isEmpty)
                  Task17StatePanel( icon: Icons.cloud_off_rounded, title: 'Không tải được bài viết',
                    message: controller.postsError!, onRetry: () => controller.loadPosts( widget.user, ),
                  )
                else if (filtered.isEmpty)
                  _emptyState()
                else ...[
                  _resultHeader( filtered.length, ),

                  const SizedBox(height: 12),
 ...filtered.map( (post) => Padding( padding: const EdgeInsets.only( bottom: 13, ), child:
                          _postCard(post), ), ), ], ], ), );
        }, ), );
  }

  Widget _headerCard( Task17SocialController controller, ) {
    return Container( padding: const EdgeInsets.all(20), decoration: BoxDecoration(
        gradient: const LinearGradient( begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
            Color(0xFFC63D00), Color(0xFFE7601E), ], ),
        borderRadius: BorderRadius.circular(28), boxShadow: const [
          BoxShadow( color: Color(0x2CA43700), blurRadius: 25, offset: Offset(0, 10), ), ], ),
      child: Row( children: [
          Container( width: 58, height: 58, decoration: BoxDecoration( color:
                  Colors.white.withValues(alpha: .17),
              borderRadius: BorderRadius.circular(19), ),
            child: const Icon( Icons.article_rounded, color: Colors.white, size: 29, ), ),

          const SizedBox(width: 15),

          Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text( 'Bài viết của bạn', style: TextStyle( color: Colors.white, fontSize: 19,
                    fontWeight: FontWeight.w800, ), ),
                const SizedBox(height: 5), Text( controller.postsLoading
                      ? 'Đang cập nhật dữ liệu...'
                      : '${controller.posts.length} bài viết',
                  style: const TextStyle( color: Color(0xFFFFE8DC), fontSize: 12, ), ), ], ), ),

          Container( padding: const EdgeInsets.symmetric( horizontal: 11, vertical: 7, ),
            decoration: BoxDecoration( color: Colors.white.withValues(alpha: .16), borderRadius:
                  BorderRadius.circular(20), ),
            child: Text( '${controller.posts.length}', style: const TextStyle( color: Colors.white,
                fontWeight: FontWeight.w800, fontSize: 15, ), ), ), ], ), );
  }

  Widget _searchField() {
    return TextField( controller: searchController, onChanged: (value) {
        setState(() {
          search = value;
        });
      }, decoration: InputDecoration( hintText: 'Tìm kiếm bài viết...', hintStyle: const TextStyle(
          color: Colors.black38, fontSize: 13, ),
        prefixIcon: const Icon( Icons.search_rounded, color: Colors.black38, ),
        suffixIcon: search.isEmpty
            ? null
            : IconButton( onPressed: () {
                  searchController.clear();

                  setState(() {
                    search = '';
                  });
                }, icon: const Icon( Icons.close_rounded, color: Colors.black38, ), ),
        filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 17, ),
        border: OutlineInputBorder( borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none,
        ), enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide( color: Color(0xFFEDE5E1), ), ),
        focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide( color: task17Orange, width: 1.5, ), ), ), );
  }

  Widget _resultHeader(int count) {
    return Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text( search.isEmpty
              ? 'Tất cả bài viết'
              : 'Kết quả tìm kiếm',
          style: const TextStyle( color: task17Text, fontSize: 15, fontWeight: FontWeight.w800, ), ),
        Text( '$count bài', style: const TextStyle( color: Colors.black38, fontSize: 11, ), ), ], );
  }

  Widget _postCard(Task17Post post) {
    return Container( padding: const EdgeInsets.all(18), decoration: BoxDecoration( color: Colors.white,
        borderRadius: BorderRadius.circular(22), border: Border.all( color: const Color(0xFFF0E9E5), ),
        boxShadow: const [
          BoxShadow( color: Color(0x0B000000), blurRadius: 17, offset: Offset(0, 6), ), ], ),
      child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row( children: [
              Container( width: 42, height: 42, decoration: BoxDecoration( color:
                      const Color(0xFFFFEEE7),
                  borderRadius: BorderRadius.circular(14), ),
                alignment: Alignment.center, child: Text( '${post.id}', style: const TextStyle(
                    color: task17Orange, fontWeight: FontWeight.w800, fontSize: 12, ), ), ),

              const SizedBox(width: 11),

              const Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text( 'Bài viết', style: TextStyle( color: task17Text, fontWeight: FontWeight.w700,
                        fontSize: 13, ), ),
                    SizedBox(height: 2), Text( 'Đã đăng', style: TextStyle( color: Colors.black38,
                        fontSize: 10, ), ), ], ), ),

              Container( width: 31, height: 31, decoration: BoxDecoration( color:
                      const Color(0xFFF8F6F4),
                  borderRadius: BorderRadius.circular(10), ),
                child: const Icon( Icons.more_horiz_rounded, color: Colors.black38, size: 18, ), ), ], ),

          const SizedBox(height: 15),

          Text( _capitalize(post.title), style: const TextStyle( color: task17Text, fontSize: 16,
              fontWeight: FontWeight.w800, height: 1.3, ), ),

          const SizedBox(height: 8),

          Text( post.body, style: const TextStyle( color: Color(0xFF6E6661), fontSize: 13, height: 1.55,
            ), ),

          const SizedBox(height: 16),

          const Divider( height: 1, color: Color(0xFFF0E9E5), ),

          const SizedBox(height: 12),

          Row( children: [
              const Icon( Icons .visibility_outlined, size: 16, color: Colors.black38, ),
              const SizedBox(width: 5), const Text( 'Công khai', style: TextStyle( color: Colors.black38,
                  fontSize: 10, ), ),

              const Spacer(),

              Container( padding: const EdgeInsets.symmetric( horizontal: 9, vertical: 5, ),
                decoration: BoxDecoration( color: const Color(0xFFFFF2EB), borderRadius:
                      BorderRadius.circular(20), ),
                child: Text( '#${post.id}', style: const TextStyle( color: task17Orange, fontSize: 10,
                    fontWeight: FontWeight.w700, ), ), ), ], ), ], ), );
  }

  Widget _emptyState() {
    return Container( padding: const EdgeInsets.symmetric( horizontal: 24, vertical: 42, ),
      decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(24),
        border: Border.all( color: const Color(0xFFF0E9E5), ), ),
      child: Column( children: [
          Container( width: 64, height: 64, decoration: const BoxDecoration( color: Color(0xFFFFF0E8),
              shape: BoxShape.circle, ),
            child: const Icon( Icons.manage_search_rounded, color: task17Orange, size: 31, ), ),

          const SizedBox(height: 15),

          const Text( 'Không tìm thấy bài viết', textAlign: TextAlign.center, style: TextStyle(
              color: task17Text, fontSize: 16, fontWeight: FontWeight.w800, ), ),

          const SizedBox(height: 6),

          Text( search.isEmpty
                ? 'Hiện chưa có bài viết nào.'
                : 'Không có kết quả phù hợp với "$search".',
            textAlign: TextAlign.center, style: const TextStyle( color: Colors.black45, fontSize: 12,
              height: 1.5, ), ),

          if (search.isNotEmpty) ...[
            const SizedBox(height: 18),

            TextButton.icon( onPressed: () {
                searchController.clear();

                setState(() {
                  search = '';
                });
              }, icon: const Icon( Icons.refresh_rounded, ), label: const Text('Xóa tìm kiếm'),
              style: TextButton.styleFrom( foregroundColor: task17Orange, ), ), ], ], ), );
  }

  Widget _loadingCard() {
    return Container( padding: const EdgeInsets.symmetric( vertical: 45, ), decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(
          color: const Color(0xFFF0E9E5), ), ),
      child: const Column( children: [
          CircularProgressIndicator( color: task17Orange, strokeWidth: 2.5, ), SizedBox(height: 13),
          Text( 'Đang tải bài viết...', style: TextStyle( color: Colors.black45, fontSize: 12, ), ), ],
      ), );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;

    return text[0].toUpperCase() + text.substring(1);
  }
}
