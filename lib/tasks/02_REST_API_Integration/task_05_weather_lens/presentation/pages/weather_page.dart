import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../data/datasources/weather_remote_data_source.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/services/search_history_service.dart';
import '../../domain/models/weather_models.dart';
import '../controllers/weather_controller.dart';


const _ink = Color(0xFF15354A);
const _blue = Color(0xFF147EBC);
const _sky = Color(0xFFEAF6FC);
const _muted = Color(0xFF6E8795);


class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late final WeatherController controller;
  final searchController = TextEditingController();

  @override

  void initState() {

    super.initState();

    controller = WeatherController(
      repository: WeatherRepository(
        remoteDataSource: WeatherRemoteDataSource(
          dio: Dio(BaseOptions(connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 12))),
        ),
      ),
      historyService: SearchHistoryService(),
    );
    controller.init();
  }

  @override
  // đóng controller và ô nhập khi rời trang 
  void dispose() {
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }


  void _search([String? city]) {
    final keyword = city ?? searchController.text.trim();
    if (keyword.isEmpty) return;
    searchController.text = keyword;
    FocusScope.of(context).unfocus();
    controller.searchCity(keyword);
  }

  // chuyển thứ trong tuần thành nhãn ngắn cho thanh chọn ngày dự báo
  String _weekday(DateTime date) {
    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return days[date.weekday - 1];
  }

  //banner gồm ô tìm tp và nút dùng vị trí thiết bị
  Widget _topPanel() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF105F99), Color(0xFF23A5CA)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.wb_sunny_outlined, color: Color(0xFFFFDC9C), size: 27),
          SizedBox(width: 9),
          Text('WEATHER LENS', style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900,
              letterSpacing: 1.6)),
        ]),
        const SizedBox(height: 12),
        const Text('Bầu trời nơi bạn đến',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                color: Colors.white)),
        const SizedBox(height: 6),
        const Text('Thời tiết hiện tại và dự báo 5 ngày tới.',
            style: TextStyle(color: Color(0xFFE0F5FC), fontSize: 12)),
        const SizedBox(height: 19),
        TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          decoration: InputDecoration(
            hintText: 'Tìm Đà Nẵng, Hà Nội, Tokyo...',
            hintStyle: const TextStyle(color: _muted, fontSize: 12),
            filled: true, fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search_rounded, color: _blue),
            suffixIcon: IconButton(onPressed: _search,
                tooltip: 'Tìm thời tiết',
                icon: const Icon(Icons.arrow_forward_rounded, color: _blue)),
            border: OutlineInputBorder(borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15)),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: controller.useCurrentLocation,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0x99FFFFFF)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
          icon: const Icon(Icons.my_location_rounded, size: 17),
          label: const Text('Xem thời tiết tại vị trí hiện tại',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  // các thành phố gợi ý giúp thử api ngay mà k cần nhập lại nhiều lần
  Widget _quickCities() {
    const cities = ['Da Nang', 'Ha Noi', 'Ho Chi Minh City', 'Tokyo'];
    return SizedBox(
      height: 41,
      child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: cities.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) => ActionChip(
          label: Text(cities[index]),
          onPressed: () => _search(cities[index]),
          backgroundColor: Colors.white,
          side: BorderSide.none,
          labelStyle: const TextStyle(fontSize: 12, color: _blue,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // H.thị 5 tp trong shared
  Widget _history() {
    if (controller.recentCities.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Text('Đã tìm gần đây',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _ink))),
        TextButton(onPressed: controller.clearHistory, child: const Text('Xóa lịch sử')),
      ]),
      const SizedBox(height: 7),
      Wrap(spacing: 7, runSpacing: 8, children: controller.recentCities.map(
        (city) => InputChip(
          avatar: const Icon(Icons.history_rounded, size: 17, color: _muted),
          label: Text(city), onPressed: () => _search(city),
          onDeleted: null,
          backgroundColor: Colors.white,
          side: BorderSide.none,
        ),
      ).toList()),
    ]);
  }

  // Thẻ lớn nhấn mạnh nhiệt độ và tình trạng trời hiện tại; dữ liệu đến từ controller.
  Widget _weatherHero(CurrentWeather current) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.place_outlined, color: _blue, size: 22),
          const SizedBox(width: 7),
          Expanded(child: Text('${current.cityName}, ${current.country}',
              style: const TextStyle(fontWeight: FontWeight.w900,
                  fontSize: 20, color: _ink))),
          IconButton(onPressed: controller.refresh, icon: const Icon(Icons.refresh_rounded,
              color: _blue), tooltip: 'Làm mới'),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${current.temperature.round()}°',
                style: const TextStyle(fontSize: 70, fontWeight: FontWeight.w900,
                    height: 1, color: _ink)),
            const SizedBox(height: 8),
            Text(current.description,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: _blue)),
            const SizedBox(height: 7),
            Text('Cảm giác như ${current.feelsLike.round()}°C',
                style: const TextStyle(fontSize: 12, color: _muted)),
          ])),
          Container(
            height: 112, width: 112,
            decoration: BoxDecoration(color: _sky, borderRadius: BorderRadius.circular(25)),
            child: current.iconUrl.isEmpty
                ? const Icon(Icons.wb_cloudy_outlined, size: 75, color: _blue)
                : CachedNetworkImage(imageUrl: current.iconUrl, fit: BoxFit.contain,
                    errorWidget: (_, _, _) => const Icon(Icons.cloud,
                        size: 70, color: _blue)),
          ),
        ]),
        const SizedBox(height: 17),
        const Divider(color: Color(0xFFE1EAF0)),
        const SizedBox(height: 13),
        Row(children: [
          _metric(Icons.water_drop_outlined, '${current.humidity}%', 'Độ ẩm'),
          _metric(Icons.air_rounded, '${current.windKmH.toStringAsFixed(1)} km/h', 'Gió'),
          _metric(Icons.speed_rounded, '${current.pressure} hPa', 'Áp suất'),
        ]),
      ]),
    );
  }


  Widget _metric(IconData icon, String value, String label) {
    return Expanded(child: Column(children: [
      Icon(icon, color: _blue, size: 22),
      const SizedBox(height: 6),
      FittedBox(fit: BoxFit.scaleDown, child: Text(value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
              color: _ink))),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 11, color: _muted)),
    ]));
  }


  Widget _forecast() {
    final dates = controller.forecastDates;
    final selected = controller.selectedForecast;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Dự báo theo ngày',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _ink)),
      const SizedBox(height: 12),
      SizedBox(height: 82, child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = dates[index];
          final chosen = DateUtils.isSameDay(controller.selectedDate, day);
          return InkWell(
            onTap: () => controller.selectDate(day),
            borderRadius: BorderRadius.circular(17),
            child: Container(
              width: 86, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: chosen ? _blue : Colors.white,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_weekday(day), style: TextStyle(color: chosen ? Colors.white : _muted,
                    fontWeight: FontWeight.w700)),
                const SizedBox(height: 7),
                Text('${day.day}/${day.month}', style: TextStyle(
                    color: chosen ? Colors.white : _ink,
                    fontWeight: FontWeight.w900)),
              ]),
            ),
          );
        },
      )),
      const SizedBox(height: 13),
      if (selected.isEmpty)
        const Text('Chưa có dữ liệu cho ngày này.',
            style: TextStyle(color: _muted))
      else
        ...selected.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(16)),
          child: Row(children: [

            SizedBox(width: 55, child: Text('${item.dateTime.hour.toString().padLeft(2, '0')}:00',
                style: const TextStyle(color: _ink, fontWeight: FontWeight.w800))),
            if (item.iconUrl.isNotEmpty)
              CachedNetworkImage(imageUrl: item.iconUrl,
                  width: 45, height: 45,


                  errorWidget: (_, _, _) => const Icon(Icons.cloud, color: _blue))
            else const Icon(Icons.cloud, color: _blue),
            const SizedBox(width: 8),
            Expanded(child: Text(item.description, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 12))),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${item.temperature.round()}°C', style: const TextStyle(
                  fontWeight: FontWeight.w900, color: _ink)),
              Text('Mưa ${(item.rainProbability * 100).round()}%',
                  style: const TextStyle(fontSize: 10, color: _blue)),
            ]),
          ]),
        )),
    ]);
  }

  //báo trạng thái rỗng/lỗi và nút thử lại
  Widget _stateCard(IconData icon, String title, String message,
      {VoidCallback? retry}) => Container(
    padding: const EdgeInsets.all(30),
    width: double.infinity,
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(24)),
    child: Column(children: [
      Icon(icon, size: 49, color: _blue),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(color: _ink, fontSize: 17,
          fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, height: 1.5)),
      if (retry != null) ...[
        const SizedBox(height: 14),
        FilledButton.icon(onPressed: retry, icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: FilledButton.styleFrom(backgroundColor: _blue)),
      ],
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: controller, builder: (context, _) {
      final bundle = controller.weather;
      return Scaffold(

        backgroundColor: _sky,
        appBar: AppBar(
          title: const Text('Weather Lens', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: _sky, foregroundColor: _ink,
          actions: [IconButton(onPressed: controller.refresh,
              icon: const Icon(Icons.refresh_rounded), tooltip: 'Làm mới')],
        ),
        body: RefreshIndicator(
          onRefresh: controller.refresh,
          color: _blue,
          child: ListView(

            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
            children: [
              _topPanel(),
              
              const SizedBox(height: 19),
              _quickCities(),
              const SizedBox(height: 20),
              if (controller.state == WeatherViewState.loading)
                const Padding(padding: EdgeInsets.all(35),
                    child: Center(child: CircularProgressIndicator(color: _blue)))
              else if (controller.state == WeatherViewState.error)
                _stateCard(Icons.cloud_off_rounded, 'Không tải được thời tiết',
                    controller.errorMessage ?? 'Đã xảy ra lỗi.',
                    retry: controller.refresh)
              else if (controller.state == WeatherViewState.success && bundle != null) ...[
                _weatherHero(bundle.current),
                const SizedBox(height: 25),
                _forecast(),
              ] else
                _stateCard(Icons.wb_sunny_outlined, 'Khám phá thời tiết',
                    'Nhập tên thành phố hoặc chọn một gợi ý để bắt đầu.'),
              const SizedBox(height: 22),
              _history(),
            ],
          ),
        ),
      );
    });
  }
}
