
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../chapter5_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../../domain/models/news_article.dart';
import '../../domain/models/sync_queue_item.dart';
import '../controllers/news_sync_controller.dart';
import '../widgets/news_sync_widgets.dart';


class NewsSyncPage
    extends StatefulWidget {
  const NewsSyncPage({
    super.key,
    this.initialTab = 0,
  });

  final int initialTab;

  @override
  State<NewsSyncPage> createState() =>
      _NewsSyncPageState();
}

class _NewsSyncPageState
    extends State<NewsSyncPage> {
  late final NewsSyncController controller;
  late int tab;

  @override

  void initState() {
    super.initState();

    tab = widget.initialTab;

    controller =
        NewsSyncController(
      newsApiKey:
          dotenv.env[ 'NEWS_API_KEY'] ??
              '',
      pixabayApiKey:
          dotenv.env[ 'PIXABAY_API_KEY'] ??
              '',
    );

    controller.initialize();
  }

  @override
  // giải phóng tài nguyên khi người dùng quay về Homepage
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  String _date(
    DateTime? value,
  ) {
    if (value == null) {
      return 'Không rõ';
    }

    return DateFormat(
      'dd/MM • HH:mm',
    ).format(
      value.toLocal(),
    );
  }

  // thông báo trạng thái sync/error bằng SnackBar
  void _snack() {
    final text =
        controller.feedback;

    if (text == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor:
              newsBackground,
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Về trang chủ 18 Tasks',
              icon: const Icon(Icons.home_rounded),
              onPressed: () => context.go('/'),
            ),
            backgroundColor:
                newsBackground,
            surfaceTintColor:
                Colors.transparent,
            title: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor:  newsRed,
                  child: Icon( Icons.newspaper,
                    color:  Colors.white,
                    size: 19,
                  ),
                ),
                const SizedBox(
                  width: 9,
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text( 'News Sync',style: TextStyle(
                          fontWeight: FontWeight
                                  .bold,
                          fontSize: 18,
                        ),
                      ),
                      Text( 'Offline-first • Bài 15',
                        style:
                            TextStyle(
                          fontSize: 10,
                          color:
                              Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller
                    .settings.workerEnabled)
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          newsSoftRed,
                      borderRadius:
                          BorderRadius
                              .circular(20),
                    ),
                    child:
                        const Text(
                      'SYNC ACTIVE',
                      style:
                          TextStyle(
                        fontSize: 9,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            newsDarkRed,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          body: _body(),
          bottomNavigationBar:
              NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: newsSoftRed,
            selectedIndex: tab,
            onDestinationSelected:
                (index) {
              setState(() {
                tab = index;
              });

              controller
                  .refreshLocal();
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(
                  Icons
                      .sync_alt_rounded,
                ),
                label: 'Sync Hub',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.newspaper,
                ),
                label: 'Offline Feed',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons
                      .pending_actions,
                ),
                label: 'Hàng đợi',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.settings,
                ),
                label: 'Cài đặt',
              ),
            ],
          ),
        );
      },
    );
  }

  // phân nhánh loading,error,ready
  Widget _body() {
    if (controller.state ==
            NewsSyncUiState.loading &&
        controller.articles.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(
          color: newsRed,
        ),
      );
    }

    return SafeArea(
      child: IndexedStack(
        index: tab,
        children: [
          _syncHub(),
          _offlineFeed(),
          _queueTab(),
          _settingsTab(),
        ],
      ),
    );
  }

  Widget _list(
    List<Widget> children,
  ) {
    return ListView(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        30,
      ),
      children: children,
    );
  }



  Widget _chapterOverview() {
    final settings = controller.settings;
    return Chapter5Hero(
      eyebrow: 'Task 15  •  Offline-first engine',
      title: 'Tin tức không gián đoạn.',
      description: 'NewsAPI + Pixabay, SQLite và hàng đợi để đọc tin đã lưu ngay cả khi mất mạng.',
      icon: Icons.auto_stories_rounded,
      from: const Color(0xFF512838),
      to: const Color(0xFFC65361),
      status: settings.workerEnabled ? 'Đang đăng ký đồng bộ' : 'Chưa bật đồng bộ nền',
      detail: '${controller.articles.length} bài đã lưu  •  ${controller.pendingCount} chờ xử lý',
    );
  }

  // dashboard hiển thị nút sync
  Widget _syncHub() {
    final session =
        controller.latestSession;

    return _list([
      _chapterOverview(),
      const SizedBox(height: 17),
      NewsPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor:
                      newsSoftRed,
                  child: Icon(
                    Icons.schedule,
                    color:
                        newsRed,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'WorkManager Periodic Sync',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                      Text(
                        'Chu kỳ '
                        '${controller.settings.intervalMinutes} phút'
                        ' • Doze-safe',
                        style:
                            const TextStyle(
                          fontSize: 11,
                          color:
                              Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  controller.settings
                          .workerEnabled
                      ? Icons
                          .check_circle
                      : Icons
                          .pause_circle_outline,
                  color:
                      controller.settings
                              .workerEnabled
                          ? newsRed
                          : Colors.black26,
                ),
              ],
            ),
            const SizedBox(
              height: 13,
            ),
            Container(
              padding:
                  const EdgeInsets.all(11),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF2F3FA,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    controller.online
                        ? Icons.wifi
                        : Icons.wifi_off,
                    color:
                        controller.online
                            ? Colors.green
                            : newsRed,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      controller.online
                          ? 'Có kết nối mạng'
                          : 'Offline • đang dùng SQLite cache',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            const Row(
              children: [
                Expanded(
                  child:
                      _ApiBadge(
                    title:
                        'NewsAPI v2',
                    subtitle:
                        'Tin tức',
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child:
                      _ApiBadge(
                    title:
                        'Pixabay',
                    subtitle:
                        'Ảnh minh họa',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      Row(
        children: [
          NewsStatCard(
            icon:
                Icons.inventory_2_outlined,
            value:
                '${controller.articles.length}',
            label:
                'Bài đã cache',
          ),
          const SizedBox(width: 8),
          NewsStatCard(
            icon:
                Icons.pending_actions,
            value:
                '${controller.pendingCount}',
            label:
                'Queue chờ',
          ),
          const SizedBox(width: 8),
          NewsStatCard(
            icon:
                Icons.history,
            value:
                '${controller.failedCount}',
            label:
                'Retry lỗi',
          ),
        ],
      ),

      const SizedBox(height: 15),

      SizedBox(
        height: 52,
        child: FilledButton.icon(
          style:
              FilledButton.styleFrom(
            backgroundColor:
                newsRed,
          ),
          onPressed:
              controller.state ==
                      NewsSyncUiState
                          .syncing
                  ? null
                  : () async {
                      await controller
                          .triggerSync();

                      if (!mounted) {
                        return;
                      }

                      _snack();
                    },
          icon:
              controller.state ==
                      NewsSyncUiState
                          .syncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.sync,
                    ),
          label:
              const Text(
            'Kích hoạt Đồng bộ Ngay',
          ),
        ),
      ),

      const SizedBox(height: 8),

      Row(
        children: [
          Expanded(
            child:
                OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  tab = 2;
                });
              },
              icon:
                  const Icon(
                Icons
                    .format_list_bulleted,
              ),
              label: Text(
                'Hàng đợi '
                '(${controller.pendingCount})',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child:
                OutlinedButton.icon(
              onPressed: () async {
                await controller
                    .cleanupCache();

                if (!mounted) {
                  return;
                }

                _snack();
              },
              icon:
                  const Icon(
                Icons
                    .cleaning_services,
              ),
              label:
                  const Text(
                'Dọn cache',
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 17),

      const Text(
        'Phiên đồng bộ gần nhất',
        style: TextStyle(
          fontWeight:
              FontWeight.bold,
          fontSize: 16,
        ),
      ),

      const SizedBox(height: 8),

      NewsPanel(
        child:
            session == null
                ? const Text(
                    'Chưa có phiên sync.',
                    style:
                        TextStyle(
                      color:
                          Colors.black45,
                    ),
                  )
                : Column(
                    children: [
                      _info(
                        'Trạng thái',
                        session.status,
                      ),
                      _info(
                        'Trigger',
                        session
                            .triggerType,
                      ),
                      _info(
                        'Tin nhận được',
                        '${session.articleCount}',
                      ),
                      _info(
                        'Tin mới',
                        '${session.newCount}',
                      ),
                      _info(
                        'Thumbnail offline',
                        '${session.imageCount}',
                      ),
                      _info(
                        'Duplicate/update',
                        '${session.duplicateCount}',
                      ),
                      _info(
                        'Queue xử lý',
                        '${session.queueProcessed}',
                      ),
                      _info(
                        'Thời gian',
                        _date(
                          session.startedAt,
                        ),
                      ),
                      if (session
                              .errorMessage !=
                          null)
                        _info(
                          'Lỗi',
                          session
                              .errorMessage!,
                        ),
                    ],
                  ),
      ),

      const SizedBox(height: 15),

      const Text(
        'Nhật ký sync',
        style: TextStyle(
          fontWeight:
              FontWeight.bold,
          fontSize: 16,
        ),
      ),

      const SizedBox(height: 8),

      NewsPanel(
        child: controller.sessions.isEmpty
            ? const Text(
                'Chưa có lịch sử.',
              )
            : Column(
                children: controller
                    .sessions
                    .take(8)
                    .map(
                  (item) {
                    final success =
                        item.status ==
                            'success';

                    return ListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      leading:
                          CircleAvatar(
                        backgroundColor:
                            success
                                ? newsSoftRed
                                : const Color(
                                    0xFFFFE3E0,
                                  ),
                        child: Icon(
                          success
                              ? Icons
                                  .cloud_done_outlined
                              : Icons
                                  .error_outline,
                          color:
                              success
                                  ? newsRed
                                  : Colors
                                      .redAccent,
                        ),
                      ),
                      title: Text(
                        '${item.triggerType}'
                        ' • +${item.newCount} tin',
                      ),
                      subtitle: Text(
                        _date(
                          item.startedAt,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
      ),
    ]);
  }

  // tab đọc tin offline với ô tìm kiếm, bộ lọc bookmark và trạng thái ảnh cache
  Widget _offlineFeed() {
    return RefreshIndicator(
      color: newsRed,
      onRefresh: () async {
        await controller
            .refreshLocal();

        if (controller.online) {
          await controller
              .triggerSync();
        }
      },
      child: _list([
        Container(
          padding:
              const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: controller.online
                ? const Color(
                    0xFFF0F3FA,
                  )
                : newsSoftRed,
            borderRadius:
                BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(
                controller.online
                    ? Icons
                        .cloud_done_outlined
                    : Icons.cloud_off,
                color: newsRed,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  controller.online
                      ? '${controller.articles.length} bài trong SQLite cache'
                      : 'Chế độ ngoại tuyến • '
                          '${controller.articles.length} bài sẵn sàng',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          onChanged:
              controller.updateSearch,
          decoration:
              InputDecoration(
            hintText:
                'Tìm tiêu đề, tác giả trong cache...',
            prefixIcon:
                const Icon(
              Icons.search,
            ),
            filled: true,
            fillColor:
                const Color(
              0xFFF0F3FA,
            ),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
              borderSide:
                  BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 7,
          children: [
            ChoiceChip(
              selected:
                  controller.filter == 'all',
              label: Text(
                'Tất cả '
                '(${controller.articles.length})',
              ),
              onSelected: (_) {
                controller
                    .setFilter('all');
              },
            ),
            ChoiceChip(
              selected:
                  controller.filter == 'bookmarked',
              label: Text(
                'Bookmark '
                '(${controller.bookmarkCount})',
              ),
              onSelected: (_) {
                controller.setFilter(
                  'bookmarked',
                );
              },
            ),
            ChoiceChip(
              selected:
                  controller.filter ==   'pending',
              label: Text(
                'Chờ sync '
                '(${controller.pendingCount})',
              ),
              onSelected: (_) {
                controller
                    .setFilter(
                  'pending',
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (controller
            .visibleArticles.isEmpty)
          const NewsPanel(
            child: Center(
              child: Padding(
                padding:
                    EdgeInsets.all(
                  20,
                ),
                child: Text(
                  'Không có bài viết phù hợp.',
                ),
              ),
            ),
          )
        else
          ...controller
              .visibleArticles
              .map(_articleCard),
      ]),
    );
  }

  // card một tin: ảnh local ưu tiên khi offline, tiêu đề, nguồn, bookmark và trạng thái đọc
  Widget _articleCard(
    NewsArticle article,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 13,
      ),
      child: NewsPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            if (article
                    .thumbnailLocalPath !=
                null)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
                child: Image.file(
                  File(
                    article
                        .thumbnailLocalPath!,
                  ),
                  height: 165,
                  width:
                      double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, _, _) =>
                          _imageFallback(
                    article,
                  ),
                ),
              )
            else
              _imageFallback(
                article,
              ),

            const SizedBox(height: 11),

            Row(
              children: [
                Expanded(
                  child: Text(
                    article.sourceName,
                    style:
                        const TextStyle(
                      color:
                          newsRed,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _date(
                    article.publishedAt,
                  ),
                  style:
                      const TextStyle(
                    fontSize: 10,
                    color:
                        Colors.black45,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Text(
              article.title,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 17,
                height: 1.3,
              ),
            ),

            if (article.description !=
                null) ...[
              const SizedBox(height: 6),
              Text(
                article.description!,
                maxLines: 2,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  color:
                      Colors.black54,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 11),

            Row(
              children: [
                const Icon(
                  Icons
                      .offline_pin_outlined,
                  size: 16,
                  color: newsRed,
                ),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    'Sẵn sàng đọc offline',
                    style:
                        TextStyle(
                      color:
                          newsRed,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await controller
                        .toggleBookmark(
                      article,
                    );

                    if (!mounted) {
                      return;
                    }

                    _snack();
                  },
                  icon: Icon(
                    article.bookmarked
                        ? Icons.bookmark
                        : Icons
                            .bookmark_border,
                    color:
                        article.bookmarked
                            ? newsRed
                            : Colors
                                .black45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // UI thay thế khi ảnh online tải lỗi; nội dung văn bản vẫn được giữ.
  Widget _imageFallback(
    NewsArticle article,
  ) {
    if (article.thumbnailUrl !=
        null) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(13),
        child: CachedNetworkImage(
          imageUrl:
              article.thumbnailUrl!,
          height: 165,
          width:
              double.infinity,
          fit: BoxFit.cover,
          placeholder:
              (_, _) =>
                  const SizedBox(
            height: 165,
            child: Center(
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget:
              (_, _, _) =>
                  _plainImage(),
        ),
      );
    }

    return _plainImage();
  }


  Widget _plainImage() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color:
            const Color(0xFFF0F3FA),
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: const Center(
        child: Icon(
          Icons
              .image_not_supported_outlined,
          size: 40,
          color: Colors.black26,
        ),
      ),
    );
  }


  Widget _queueTab() {
    final waiting = controller.queue
        .where((item) => item.pending || item.failed)
        .toList();
    final finished = controller.queue
        .where((item) => !item.pending && !item.failed)
        .toList();

    return _list([
      NewsPanel(
        child: Column(
          children: [
            Icon(
              waiting.isEmpty
                  ? Icons.task_alt_rounded
                  : Icons.cloud_sync_rounded,
              size: 52,
              color: waiting.isEmpty ? Colors.green : newsRed,
            ),
            const SizedBox(height: 9),
            Text(
              waiting.isEmpty
                  ? 'Không có thao tác cần xử lý'
                  : '${controller.pendingCount} đang chờ • ${controller.failedCount} bị lỗi',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 7),
            Text(
              waiting.isEmpty
                  ? 'Các thao tác lưu tin đã được ghi trên thiết bị.'
                  : 'Ứng dụng tự thử lại khi có mạng. Thời điểm chạy còn phụ thuộc Android.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
            ),
            if (controller.pendingCount > 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await controller.retryQueue();
                    if (mounted) _snack();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Yêu cầu thử lại'),
                  style: FilledButton.styleFrom(backgroundColor: newsRed),
                ),
              ),
            ],
          ],
        ),
      ),
      if (waiting.isNotEmpty) ...[
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 2, 4, 8),
          child: Text(
            'Cần xử lý',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ...waiting.map(_queueItem),
      ],
      if (finished.isNotEmpty) ...[
        const SizedBox(height: 14),
        NewsPanel(
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history_rounded, color: newsRed),
            title: Text('Lịch sử thao tác (${finished.length})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text(
              'Đã ghi nhận trong ứng dụng; không phải xác nhận từ máy chủ.',
              style: TextStyle(fontSize: 12),
            ),
            children: [
              const SizedBox(height: 8),
              ...finished.take(20).map(_queueItem),
            ],
          ),
        ),
      ],
      if (controller.failedCount > 0) ...[
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () async {
            await controller.clearFailed();
            if (mounted) _snack();
          },
          icon: const Icon(Icons.delete_sweep_rounded),
          label: const Text('Dọn các thao tác đã lỗi'),
        ),
      ],
    ]);
  }


  Widget _queueItem(
    SyncQueueItem item,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: NewsPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      item.failed
                          ? const Color(
                              0xFFFFE0DD,
                            )
                          : newsSoftRed,
                  child: Icon(
                    item.action ==
                            'bookmark_upsert'
                        ? Icons.bookmark
                        : Icons
                            .mark_email_read_outlined,
                    color:
                        item.failed
                            ? Colors
                                .redAccent
                            : newsRed,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    item.action == 'bookmark_upsert'
                        ? 'Cập nhật tin đã lưu'
                        : item.action == 'read_state'
                            ? 'Đánh dấu đã đọc'
                            : 'Thao tác trên thiết bị',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF0F3FA,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child: Text(
                    item.status == 'done'
                        ? 'Đã ghi nhận'
                        : item.status == 'failed'
                            ? 'Cần kiểm tra'
                            : item.status == 'retry'
                                ? 'Chờ thử lại'
                                : 'Đang chờ',
                    style:
                        const TextStyle(
                      fontSize: 10,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              'Số lần thử: '
              '${item.attemptCount}/5',
            ),

            if (item.nextRetryAt !=
                null)
              Text(
                'Thử lại dự kiến: '
                '${_date(item.nextRetryAt)}',
                style:
                    const TextStyle(
                  fontSize: 11,
                  color:
                      Colors.black54,
                ),
              ),

            if (item.lastError !=
                null) ...[
              const SizedBox(height: 5),
              Text(
                item.lastError!,
                style:
                    const TextStyle(
                  color:
                      Colors.redAccent,
                  fontSize: 11,
                ),
              ),
            ],

            const SizedBox(height: 8),



          ],
        ),
      ),
    );
  }


  Widget _settingsTab() {
    const intervals =
        [15, 30, 60, 180];

    return _list([
      NewsPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Tự động cập nhật tin',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 10),

            SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,
              title:
                  const Text(
                'Đồng bộ nền tự động',
              ),
              subtitle:
                  const Text(
                'Đồng bộ tin và ảnh '
                'trong background',
              ),
              value:
                  controller.settings
                      .workerEnabled,
              onChanged:
                  (value) async {
                if (value) {
                  await controller
                      .registerWorker();
                } else {
                  await controller
                      .cancelWorker();
                }

                if (!mounted) {
                  return;
                }

                _snack();
              },
            ),

            const Divider(),

            SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,
              title:
                  const Text(
                'Chỉ dùng mạng không tính phí dữ liệu',
              ),
              subtitle:
                  const Text(
                'Thường là Wi-Fi; có thể trì hoãn đồng bộ nếu đang dùng 4G/5G.',
              ),
              value:
                  controller.settings
                      .wifiOnly,
              onChanged:
                  controller
                      .setWifiOnly,
            ),

            const Divider(),

            SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,
              title:
                  const Text(
                'Thông báo khi có tin mới',
              ),
              value:
                  controller.settings
                      .notificationsEnabled,
              onChanged:
                  controller
                      .setNotifications,
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      NewsPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Chu kỳ đồng bộ',
              style:
                  TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              children:
                  intervals.map(
                (value) {
                  final selected =
                      controller
                              .settings
                              .intervalMinutes ==
                          value;

                  final label =
                      value < 60
                          ? '${value}p'
                          : '${value ~/ 60}h';

                  return ChoiceChip(
                    selected:
                        selected,
                    label:
                        Text(label),
                    onSelected:
                        (_) {
                      controller
                          .setInterval(
                        value,
                      );
                    },
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      NewsPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Nguồn dữ liệu',
              style:
                  TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _info(
              'Nguồn tin',
              'NewsAPI • chủ đề mobile',
            ),
            _info(
              'Ảnh minh họa',
              'Pixabay',
            ),
            _info(
              'Lưu trữ',
              'SQLite trên điện thoại',
            ),
            _info(
              'Thao tác offline',
              'Lưu lại để xử lý khi có mạng',
            ),
            _info(
              'Thử lại',
              'Tăng thời gian chờ • tối đa 5 lần',
            ),
          ],
        ),
      ),
    ]);
  }

  // Một dòng chỉ số/nhãn dùng chung trong các phần giao diện.
  Widget _info(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              color:
                  Colors.black45,
              fontSize: 11,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// nhãn hiển thị nguồn aoi trong ui
class _ApiBadge
    extends StatelessWidget {
  const _ApiBadge({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF2F3FA),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color:
                Colors.green,
            size: 17,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style:
                const TextStyle(
              fontSize: 10,
              color:
                  Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}