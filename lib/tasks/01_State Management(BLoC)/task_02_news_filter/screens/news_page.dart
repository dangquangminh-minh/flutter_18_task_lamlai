import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../services/news_service.dart';
import '../widgets/article_card.dart';


class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        // đọc key
        final apiKey = dotenv.env['NEWS_API_KEY']?.trim() ?? '';

        final bloc = NewsBloc(NewsService(apiKey: apiKey));

        // ch có dl thì tải trag đầu
        // có cache thì h.thị dl cũ trc
        if (bloc.state.status == NewsStatus.initial) {
          bloc.add(const NewsRequested());
        }

        return bloc;
      },
      child: const _NewsView(),
    );
  }
}

class _NewsView extends StatefulWidget {
  const _NewsView();

  @override
  State<_NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<_NewsView> {
  static const orange = Color(0xFFF26B0A);
  static const dark = Color(0xFF292929);

  final _searchController = TextEditingController();

  final _scrollController = ScrollController();

  final _topics = const [
    'Tất cả',
    'Công nghệ',
    'Kinh doanh',

    'Thể thao',
    'Khoa học',
  ];

  @override
  void initState() {
    super.initState();

    _searchController.text = context.read<NewsBloc>().state.query;

    // theo dõi vị trí cuộn
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;


    if (position.pixels >= position.maxScrollExtent - 250) {
      context.read<NewsBloc>().add(const LoadMoreNews());
    }
  }


  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // header vs ô tìm kiếm
  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFED6500), Color(0xFFFF9A45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DISCOVER THE WORLD',
                      style: TextStyle(
                        color: Color(0xFFFFE9D5),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tin tức mỗi ngày',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Tìm kiếm những chủ đề bạn quan tâm.',
                      style: TextStyle(
                        color: Color(0xFFFFF0E3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 42,
              ),
            ],
          ),
          const SizedBox(height: 19),


          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              _scrollToTop();
              context.read<NewsBloc>().add(SearchChanged(value));
            },
            onSubmitted: (_) {
              FocusScope.of(context).unfocus();
              context.read<NewsBloc>().add(const NewsRequested());
            },
            decoration: InputDecoration(
              hintText: 'Tìm bài viết, công nghệ, thể thao...',

              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFAAAAAA),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: orange,
              ),
              suffixIcon: IconButton(
                tooltip: 'Xóa tìm kiếm',
                onPressed: () {
                  _searchController.clear();
                  _scrollToTop();
                  context.read<NewsBloc>().add(const SearchChanged(''));
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.grey,
                  size: 19,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 16,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ds chọn chủ đề tin
  Widget _topicBar() {
    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        return SizedBox(
          height: 65,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: _topics.map((topic) {
              final selected = state.topic == topic;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(topic),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: orange,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selected
                        ? orange
                        : const Color(0xFFF0DED0),
                  ),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : dark,
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    _scrollToTop();
                    context.read<NewsBloc>().add(TopicChanged(topic));
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // h.thị tiêu đề ds và menu sx
  Widget _sortBar() {
    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(17, 0, 17, 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Khám phá bài viết',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: dark,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Sắp xếp bài viết',
                onSelected: (value) {
                  _scrollToTop();
                  context.read<NewsBloc>().add(SortChanged(value));
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'publishedAt',
                    child: Text('Mới nhất'),
                  ),
                  PopupMenuItem(
                    value: 'popularity',
                    child: Text('Phổ biến'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11, vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: const Color(0xFFF1DFD0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sort_rounded,
                        color: orange,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.sortBy == 'publishedAt'
                            ? 'Mới nhất'
                            : 'Phổ biến',
                        style: const TextStyle(
                          color: orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: orange,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // chờ api trả dl
  Widget _loadingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: orange),
          SizedBox(height: 16),
          Text(
            'Đang tải tin tức...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Đang lấy dữ liệu từ NewsAPI',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }


  Widget _messageView({
    required IconData icon,
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECDC),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: orange),
            ),
            const SizedBox(height: 17),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
                style: FilledButton.styleFrom(
                  backgroundColor: orange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Fdùng cho trạng thái p.trag
  Widget _listFooter(NewsState state) {
    if (state.status == NewsStatus.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(22),
        child: Center(
          child: CircularProgressIndicator(color: orange),
        ),
      );
    }

    if (state.loadMoreError.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              state.loadMoreError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () {
                context.read<NewsBloc>().add(const RetryLoadMore());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử tải tiếp'),
            ),
          ],
        ),
      );
    }

    if (!state.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Bạn đã xem hết kết quả',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    return const SizedBox(height: 24);
  }

  // tạo ds bài báo
  Widget _articleList(NewsState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 20),


      itemCount: state.articles.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {

          return Padding(
            padding: const EdgeInsets.fromLTRB(17, 0, 17, 13),
            child: Row(
              children: [
                const Icon(
                  Icons.article_outlined,
                  color: orange,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  'Đã tải ${state.articles.length} / ${state.totalResults} kết quả',

                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        if (index <= state.articles.length) {

          return ArticleCard(
            article: state.articles[index - 1],
          );
        }

        return _listFooter(state);
      },
    );
  }

  // dựa vào state để h.thị giao diện 
  Widget _buildNewsBody(NewsState state) {
    if (state.status == NewsStatus.initial ||
        state.status == NewsStatus.loading) {
      return _loadingView();
    }

    if (state.status == NewsStatus.failure) {
      return _messageView(
        icon: Icons.wifi_off_rounded,
        title: 'Không tải được tin tức'  ,
        message: state.errorMessage,
        onRetry: () {

          context.read<NewsBloc>().add(const NewsRequested());
        },
      );
    }

    if (state.status == NewsStatus.empty) {
      return _messageView(
        icon: Icons.search_off_rounded,
        title: 'Không tìm thấy bài viết',
        message: 'Hãy thử từ khóa hoặc chủ đề khác.',
      );
    }

    return _articleList(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: orange,
        foregroundColor: Colors.white,
        title: const Text(
          'News Filter Hub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // nút tải lại ds
          IconButton(
            tooltip: 'Làm mới tin tức',
            onPressed: () {
              context.read<NewsBloc>().add(const NewsRequested());
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _topicBar(),
            _sortBar(),


            Expanded(
              child: BlocBuilder<NewsBloc, NewsState>(
                builder: (context, state) {
                  return _buildNewsBody(state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}