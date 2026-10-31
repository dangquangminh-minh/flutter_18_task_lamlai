import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/country_model.dart';
import '../../domain/models/weather_model.dart';
import '../bloc/favorite/favorite_cubit.dart';
import '../bloc/weather/weather_bloc.dart';
import '../bloc/weather/weather_event.dart';
import '../bloc/weather/weather_state.dart';
import '../travel_theme.dart';

class WeatherDetailPage extends StatefulWidget {
  final CountryModel country;

  const WeatherDetailPage({
    super.key,
    required this.country,
  });

  @override
  State<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  @override
  void initState() {
    super.initState();

    // khi mở chi tiết, gửi sk để lấy thời tiết thủ đô
    context.read<WeatherBloc>().add(
      WeatherRequested(widget.country),
    );
  }

  void _retry() {
    context.read<WeatherBloc>().add(
      const WeatherRetryRequested(),
    );
  }

  String _formatTime(DateTime date) {
    final local = date.toLocal();

    String two(int number) => number.toString().padLeft(2, '0');

    return '${two(local.hour)}:${two(local.minute)} '
        '${two(local.day)}/${two(local.month)}/${local.year}';
  }

  // thẻ thông số dùng chug
  Widget _statTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5EBE8)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 25, color: travelPrimary),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: travelMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: travelText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // thẻ nh độ
  Widget _weatherHero(WeatherModel weather, bool fromCache) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF143541),
            Color(0xFF287F79),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFFD7EEE9),
                size: 19,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${widget.country.capital}, ${widget.country.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (fromCache)
                const Icon(
                  Icons.offline_bolt_rounded,
                  color: Color(0xFFFFD09A),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 71,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      weather.description.isEmpty
                          ? 'Không rõ điều kiện thời tiết'
                          : weather.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cảm giác như ${weather.feelsLike.round()}°C',
                      style: const TextStyle(
                        color: Color(0xFFD8ECE7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: weather.iconUrl.isEmpty
                    ? const Icon(
                        Icons.cloud_outlined,
                        size: 76,
                        color: Colors.white,
                      )
                    : Image.network(
                        weather.iconUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.cloud_outlined,
                          size: 76,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Divider(
            color: Colors.white.withValues(alpha: 0.20),
          ),
          const SizedBox(height: 8),

          // Dữ liệu từ cache không được hiển thị như thời tiết trực tiếp.
          Text(
            fromCache
                ? 'DỮ LIỆU ĐÃ LƯU · ${_formatTime(weather.updatedAt)}'
                : 'CẬP NHẬT · ${_formatTime(weather.updatedAt)}',
            style: const TextStyle(
              color: Color(0xFFDFEDE9),
              fontSize: 10,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // h.thị các mốc dự báo
  Widget _hourlyForecast(List<HourlyWeatherModel> items) {
    if (items.isEmpty) {
      return const Text(
        'Chưa có dữ liệu dự báo theo giờ.',
        style: TextStyle(color: travelMuted, fontSize: 12),
      );
    }

    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final hour = item.time.toLocal().hour.toString().padLeft(2, '0');

          return Container(
            width: 91,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              children: [
                Text(
                  '$hour:00',
                  style: const TextStyle(
                    fontSize: 11,
                    color: travelMuted,
                  ),
                ),
                const SizedBox(height: 7),
                Expanded(
                  child: item.iconUrl.isEmpty
                      ? const Icon(
                          Icons.wb_cloudy_outlined,
                          color: travelPrimary,
                          size: 28,
                        )
                      : Image.network(
                          item.iconUrl,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.wb_cloudy_outlined,
                            color: travelPrimary,
                          ),
                        ),
                ),
                Text(
                  '${item.temperature.round()}°C',
                  style: const TextStyle(
                    color: travelText,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _countryInformation() {
    final country = widget.country;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        children: [
          _infoRow('Quốc gia', country.name),
          const Divider(height: 22),
          _infoRow('Thủ đô', country.capital),
          const Divider(height: 22),
          _infoRow('Khu vực', country.region),
          const Divider(height: 22),
          _infoRow('Ngôn ngữ', country.language),
          const Divider(height: 22),
          _infoRow('Tiền tệ', country.currencyCode),
          const Divider(height: 22),
          _infoRow('Múi giờ', country.timezone),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: travelMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value.isEmpty ? 'Chưa có dữ liệu' : value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: travelText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _content(WeatherModel weather, bool fromCache) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      children: [
        _weatherHero(weather, fromCache),
        const SizedBox(height: 25),

        const Text(
          'Chi tiết thời tiết',
          style: TextStyle(
            color: travelText,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 13),

        Row(
          children: [
            Expanded(
              child: _statTile(
                Icons.water_drop_outlined,
                'Độ ẩm',
                '${weather.humidity}%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statTile(
                Icons.air_rounded,
                'Tốc độ gió',
                '${weather.windSpeedKmh.toStringAsFixed(1)} km/h',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statTile(
                Icons.compress_rounded,
                'Áp suất',
                '${weather.pressure} hPa',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statTile(
                Icons.visibility_outlined,
                'Tầm nhìn',
                '${weather.visibilityKm.toStringAsFixed(1)} km',
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),
        const Text(
          'Dự báo sắp tới',
          style: TextStyle(
            color: travelText,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 13),
        _hourlyForecast(weather.hourly),

        const SizedBox(height: 25),
        const Text(
          'Thông tin điểm đến',
          style: TextStyle(
            color: travelText,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 13),
        _countryInformation(),
      ],
    );
  }

  Widget _errorView(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: travelPrimary,
            ),
            const SizedBox(height: 13),
            const Text(
              'Không tải được thời tiết',
              style: TextStyle(
                color: travelText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Có lỗi khi tải dữ liệu.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: travelMuted),
            ),
            const SizedBox(height: 17),
            FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: FilledButton.styleFrom(
                backgroundColor: travelPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: travelBackground,
      appBar: AppBar(
        backgroundColor: travelBackground,
        foregroundColor: travelText,
        title: const Text(
          'Thời tiết điểm đến',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới thời tiết',
            onPressed: _retry,
            icon: const Icon(Icons.refresh_rounded),
          ),
          BlocBuilder<FavoriteCubit, FavoriteState>(
            builder: (context, state) {
              final favorite = state.isFavorite(widget.country.code);

              return IconButton(
                tooltip: favorite ? 'Bỏ yêu thích' : 'Lưu yêu thích',
                onPressed: () {
                  context.read<FavoriteCubit>().toggle(widget.country);
                },
                icon: Icon(
                  favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: favorite
                      ? travelPrimaryContainer
                      : travelMuted,
                ),
              );
            },
          ),
        ],
      ),

      // WeatherBloc quản lý trạng thái loading, success và failure.
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state.status == WeatherStatus.loading ||
              state.status == WeatherStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: travelPrimary),
            );
          }

          if (state.status == WeatherStatus.failure ||
              state.weather == null) {
            return _errorView(state.message);
          }

          return _content(
            state.weather!,
            state.fromCache,
          );
        },
      ),
    );
  }
}