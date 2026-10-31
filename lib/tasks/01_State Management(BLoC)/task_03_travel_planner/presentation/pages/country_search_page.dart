import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/country_model.dart';
import '../../network_info.dart';
import '../../travel_injection.dart';
import '../bloc/country/country_bloc.dart';
import '../bloc/country/country_event.dart';
import '../bloc/country/country_state.dart';
import '../bloc/favorite/favorite_cubit.dart';
import '../bloc/weather/weather_bloc.dart';
import '../travel_theme.dart';
import 'weather_detail_page.dart';

class CountrySearchPage extends StatefulWidget {
  const CountrySearchPage({super.key});

  @override
  State<CountrySearchPage> createState() => _CountrySearchPageState();
}

class _CountrySearchPageState extends State<CountrySearchPage> {
  final searchController = TextEditingController();

  // các nút tìm nhanh giúp người dùng thử chức năng tìm kiếm
  final quickCountries = const [
    'Vietnam', 'Japan', 'France', 'Canada', 'Germany',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // gửi từ khóa tìm kiếm 
  // nếu không nhập gì thì quay về bốn quốc gia gợi 
  void _search([String? countryName]) {
    if (countryName != null) {
      searchController.text = countryName;
    }

    final query = searchController.text.trim();

    FocusScope.of(context).unfocus();

    if (query.isEmpty) {
      context.read<CountryBloc>().add(const CountryStarted());
    } else {
      context.read<CountryBloc>().add(
        CountrySearchRequested(query),
      );
    }
  }

  // refesh đợi bloc x.lý xong mới tắt vòng quay
  Future<void> _refresh() async {
    final bloc = context.read<CountryBloc>();

    final finished = bloc.stream.firstWhere(
      (state) =>
          state.status == CountryStatus.success ||
          state.status == CountryStatus.empty ||
          state.status == CountryStatus.failure,
    );

    _search();
    await finished;
  }

  // mở trang thời tiết và truyền lại các bloC đang dùng.
  void _openWeather(CountryModel country) {
    final weatherBloc = context.read<WeatherBloc>();
    final favoriteCubit = context.read<FavoriteCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<WeatherBloc>.value(value: weatherBloc),
            BlocProvider<FavoriteCubit>.value(value: favoriteCubit),
          ],
          child: WeatherDetailPage(country: country),
        ),
      ),
    );
  }

  //phần giới thiệu 
  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: travelSecondary,
        borderRadius: BorderRadius.circular(27),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THE WORLD IS YOURS',
                      style: TextStyle(
                        color: Color(0xFFB4D9D4),
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 9),
                    Text(
                      'Đi đâu tiếp theo?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Khám phá thế giới, xem thời tiết '
                      'và lưu điểm đến yêu thích.',
                      style: TextStyle(
                        color: Color(0xFFD2E3DF),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.travel_explore_rounded,
                color: Color(0xFFE7AE81),
                size: 54,
              ),
            ],
          ),
          const SizedBox(height: 22),

          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Tìm Vietnam, Japan, France...',
              hintStyle: const TextStyle(
                color: Color(0xFF9BAAA9),
                fontSize: 12,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: travelPrimary,
              ),
              suffixIcon: IconButton(
                tooltip: 'Tìm quốc gia',
                onPressed: _search,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: travelPrimary,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // các nút tìm nhanh, thay thế bộ lọc khu vực cũ

  Widget _quickSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TÌM KIẾM NHANH',
          style: TextStyle(
            color: travelMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 41,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: quickCountries.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final name = quickCountries[index];

              return ActionChip(
                label: Text(name),
                onPressed: () => _search(name),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE0E9E5)),
                labelStyle: const TextStyle(
                  color: travelText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // chỉ báo trạng thái kết nối thiết bị
  Widget _connectionStatus() {
    return StreamBuilder<bool>(
      stream: sl<NetworkInfo>().statusStream,
      builder: (context, snapshot) {
        final online = snapshot.data;

        final label = online == null
            ? 'Đang kiểm tra kết nối'
            : online
                ? 'Có kết nối mạng'
                : 'Ngoại tuyến';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              online == false
                  ? Icons.wifi_off_rounded
                  : Icons.wifi_rounded,
              size: 15,
              color: travelPrimary,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: travelMuted,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // card báo lỗi hoặc danh sách rỗng
  Widget _messageCard({
    required IconData icon,
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(icon, size: 45, color: travelPrimary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: travelText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: travelMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: FilledButton.styleFrom(
                backgroundColor: travelPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // thẻ quốc gia
  Widget _countryTile(CountryModel country) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: () => _openWeather(country),
        borderRadius: BorderRadius.circular(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(
              height: 112,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(19),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 112,
                      color: travelSoftBlue,
                      padding: const EdgeInsets.all(20),
                      child: country.flagUrl.isEmpty
                          ? const Icon(
                              Icons.flag_rounded,
                              size: 46,
                              color: travelPrimary,
                            )
                          : Image.network(
                              country.flagUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) {
                                return const Icon(
                                  Icons.flag_rounded,
                                  size: 46,
                                  color: travelPrimary,
                                );
                              },
                            ),
                    ),
                  ),

                  Positioned(
                    right: 6,
                    top: 6,
                    child: BlocBuilder<FavoriteCubit, FavoriteState>(
                      builder: (context, state) {
                        final saved = state.isFavorite(country.code);

                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            tooltip: saved
                                ? 'Bỏ yêu thích'
                                : 'Thêm yêu thích',
                            iconSize: 19,
                            onPressed: () {
                              context.read<FavoriteCubit>().toggle(country);
                            },
                            icon: Icon(
                              saved
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: saved
                                  ? travelPrimaryContainer
                                  : travelMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: travelText,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      country.capital.isEmpty
                          ? 'Chưa rõ thủ đô'
                          : country.capital,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: travelMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      country.region,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: travelPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Xem thời tiết',
                            maxLines: 1,
                            style: TextStyle(
                              color: travelPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 16,
                          color: travelPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _resultContent(CountryState state) {
    if (state.status == CountryStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 55),
        child: Center(
          child: CircularProgressIndicator(color: travelPrimary),
        ),
      );
    }

    if (state.status == CountryStatus.failure) {
      return _messageCard(
        icon: Icons.cloud_off_rounded,
        title: 'Không tải được quốc gia',
        message: state.message ?? 'Đã xảy ra lỗi khi tải dữ liệu.',
        onRetry: () {
          context.read<CountryBloc>().add(
            const CountryRetryRequested(),
          );
        },
      );
    }

    if (state.status == CountryStatus.empty ||
        state.countries.isEmpty) {
      return _messageCard(
        icon: Icons.travel_explore_outlined,
        title: 'Không có quốc gia phù hợp',
        message: 'Thử tìm bằng tên tiếng Anh như Vietnam hoặc Japan.',
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 650;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.fromCache) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9D5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.offline_bolt_rounded,
                  color: Color(0xFF9E6137),
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đang hiển thị quốc gia đã lưu trên thiết bị',
                    style: TextStyle(
                      color: Color(0xFF9E6137),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],


        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.countries.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wide ? 3 : 2,
            mainAxisSpacing: 13,
            crossAxisSpacing: 13,
            childAspectRatio: wide ? 0.88 : 0.60,
          ),
          itemBuilder: (context, index) {
            return _countryTile(state.countries[index]);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: travelPrimary,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        children: [
          _hero(),
          const SizedBox(height: 22),
          _quickSearch(),
          const SizedBox(height: 24),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Điểm đến dành cho bạn',
                  style: TextStyle(
                    fontSize: 19,
                    color: travelText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _connectionStatus(),
            ],
          ),
          const SizedBox(height: 15),

          BlocBuilder<CountryBloc, CountryState>(
            builder: (context, state) => _resultContent(state),
          ),
        ],
      ),
    );
  }
}