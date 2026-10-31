import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/country_model.dart';
import '../../domain/models/weather_model.dart';
import '../../network_info.dart';
import '../../travel_injection.dart';
import '../bloc/favorite/favorite_cubit.dart';
import '../bloc/weather/weather_bloc.dart';
import '../travel_theme.dart';
import 'weather_detail_page.dart';

class OfflineSavedPage extends StatelessWidget {
  const OfflineSavedPage({super.key});

  // mở thời tiết của 1 qg đã lưu
  void _openWeather(BuildContext context, CountryModel country) {
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

  String _date(DateTime? date) {
    if (date == null) return 'Chưa có lần đồng bộ';

    final local = date.toLocal();

    String two(int number) => number.toString().padLeft(2, '0');

    return '${two(local.hour)}:${two(local.minute)} '
        '${two(local.day)}/${two(local.month)}/${local.year}';
  }

  // banner đầu trang hiển thị tình trạng bộ nhớ off
  Widget _header(FavoriteState state) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: travelSecondary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.bookmark_added_rounded,
            size: 37,
            color: Color(0xFFE6B38B),
          ),
          const SizedBox(height: 15),
          const Text(
            'Bộ sưu tập của bạn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Những nơi bạn muốn khám phá, '
            'được lưu để xem lại khi mất mạng.',
            style: TextStyle(
              color: Color(0xFFD9E8E4),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _headerStat(
                  '${state.favorites.length}',
                  'Quốc gia đã lưu',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _headerStat(
                  '${state.weatherByCode.length}',
                  'Bản thời tiết',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE0EEEA),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // hiển thị kết nối và thời điểm đồng bộ gần nhất
  Widget _connectionCard(FavoriteState state) {
    return StreamBuilder<bool>(
      stream: sl<NetworkInfo>().statusStream,
      builder: (context, snapshot) {
        final online = snapshot.data;

        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: travelSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                online == false
                    ? Icons.cloud_off_outlined
                    : Icons.cloud_done_outlined,
                color: travelPrimary,
                size: 26,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      online == null
                          ? 'Đang kiểm tra kết nối'
                          : online
                              ? 'Thiết bị có kết nối mạng'
                              : 'Đang ở chế độ ngoại tuyến',
                      style: const TextStyle(
                        color: travelText,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Đồng bộ: ${_date(state.lastSync)}',
                      style: const TextStyle(
                        color: travelMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // h.thị 1 qg yêu thích
  Widget _savedCard(
    BuildContext context,
    CountryModel country,
    WeatherModel? weather,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openWeather(context, country),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 65,
                  height: 67,
                  padding: const EdgeInsets.all(7),
                  color: travelSoftBlue,
                  child: country.flagUrl.isEmpty
                      ? const Icon(
                          Icons.flag_outlined,
                          color: travelPrimary,
                        )
                      : Image.network(
                          country.flagUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.flag_outlined,
                            color: travelPrimary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: travelText,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      country.capital.isEmpty
                          ? 'Không có thông tin thủ đô'
                          : country.capital,
                      style: const TextStyle(
                        color: travelMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weather == null
                          ? 'Chưa lưu thời tiết'
                          : '${weather.temperature.round()}°C · '
                              '${weather.description}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: travelPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // xóa qg khỏi ds yêu thích
              IconButton(
                tooltip: 'Bỏ yêu thích',
                onPressed: () {
                  context.read<FavoriteCubit>().toggle(country);
                },
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: travelPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //xá nhận trc khi dọn cache
  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dọn dữ liệu tạm?'),
        content: const Text(
          'Thông tin thời tiết và kết quả tìm kiếm đã lưu '
          'sẽ bị xóa. Danh sách yêu thích vẫn được giữ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Dọn cache'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<FavoriteCubit>().clearCache();
    }
  }

  // nút đồng bộ khi có mạng
  Widget _syncButton(BuildContext context, FavoriteState state) {
    return StreamBuilder<bool>(
      stream: sl<NetworkInfo>().statusStream,
      builder: (context, snapshot) {
        final online = snapshot.data == true;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: online && !state.syncing
                ? () => context.read<FavoriteCubit>().sync()
                : null,
            icon: state.syncing
                ? const SizedBox(
                    height: 17,
                    width: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sync_rounded),
            label: Text(
              state.syncing
                  ? 'Đang đồng bộ...'
                  : 'Đồng bộ thời tiết đã lưu',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: travelPrimary,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteCubit, FavoriteState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: travelPrimary,
          onRefresh: () => context.read<FavoriteCubit>().load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
            children: [
              _header(state),
              const SizedBox(height: 15),
              _connectionCard(state),
              const SizedBox(height: 25),

              const Text(
                'Địa điểm yêu thích',
                style: TextStyle(
                  color: travelText,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              if (state.loading && state.favorites.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(35),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: travelPrimary,
                    ),
                  ),
                )
              else if (state.favorites.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        color: travelPrimary,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Bạn chưa lưu địa điểm nào',
                        style: TextStyle(
                          color: travelText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Chọn một quốc gia ở tab Khám phá '
                        'và nhấn biểu tượng trái tim.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: travelMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...state.favorites.map(
                  (country) => _savedCard(
                    context,
                    country,
                    state.weatherByCode[country.code],
                  ),
                ),

              if (state.message != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.message!,
                  style: const TextStyle(
                    color: travelPrimaryContainer,
                  ),
                ),
              ],

              const SizedBox(height: 24),
              _syncButton(context, state),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmClear(context),
                  icon: const Icon(Icons.cleaning_services_outlined),
                  label: const Text('Dọn bộ nhớ đệm'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}