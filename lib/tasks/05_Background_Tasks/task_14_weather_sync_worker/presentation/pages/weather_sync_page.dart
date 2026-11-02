
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../chapter5_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../../domain/models/weather_snapshot.dart';
import '../../domain/models/weather_sync_event.dart';
import '../../domain/models/weather_sync_settings.dart';
import '../controllers/weather_sync_controller.dart';
import '../widgets/weather_sync_widgets.dart';


class WeatherSyncPage
    extends StatefulWidget {
  const WeatherSyncPage({
    super.key,
    this.initialTab = 0,
  });

  final int initialTab;

  @override
  State<WeatherSyncPage> createState() =>
      _WeatherSyncPageState();
}

class _WeatherSyncPageState
    extends State<WeatherSyncPage> {
  late final WeatherSyncController controller;

  late int tab;

  @override
  // Khởi tạo controller khi trang xuất hiện, tránh tạo worker mới mỗi lần rebuild.
  void initState() {
    super.initState();

    tab = widget.initialTab;

    controller =
        WeatherSyncController(
      apiKey:
          dotenv.env[
                  'OPENWEATHER_API_KEY'] ??
              '',
    );

    controller.initialize();
  }

  @override
  // giải phóng controller
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // định dạng thời điểm đồng bộ cuối cùng để người dùng phân biệt dl mới và cache
  String _time(DateTime value) {
    return DateFormat(
      'dd/MM • HH:mm',
    ).format(value);
  }


  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override

  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor:
              weatherBackground,
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Về trang chủ 18 Tasks',
              icon: const Icon(Icons.home_rounded),
              onPressed: () => context.go('/'),
            ),
            backgroundColor:
                weatherBackground,
            surfaceTintColor:
                Colors.transparent,
            title: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      weatherOrange,
                  child: Icon(
                    Icons.sync_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weather Sync',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Cập nhật tự động theo lịch',
                        style: TextStyle(
                          fontSize: 11,
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
                          weatherSoftOrange,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: const Text(
                      'ĐÃ BẬT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            weatherDarkOrange,
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
            indicatorColor: weatherSoftOrange,
            selectedIndex: tab,
            onDestinationSelected:
                (value) {
              setState(() {
                tab = value;
              });

              controller.reloadCache();
            },
            destinations: const [
              NavigationDestination(
                icon:
                    Icon(Icons.tune),
                label: 'Cài đặt',
              ),
              NavigationDestination(
                icon:
                    Icon(Icons.cloud),
                label: 'Thời tiết',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons
                      .notifications_active_outlined,
                ),
                label: 'Cảnh báo',
              ),
              NavigationDestination(
                icon:
                    Icon(Icons.history),
                label: 'Lịch sử',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _body() {
    if (controller.status ==
            WeatherSyncStatus.loading &&
        controller.snapshots.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(
          color: weatherOrange,
        ),
      );
    }

    return SafeArea(
      child: IndexedStack(
        index: tab,
        children: [
          _settingsTab(),
          _weatherTab(),
          _alertsTab(),
          _historyTab(),
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
        28,
      ),
      children: children,
    );
  }


  Widget _chapterOverview() {
    final settings = controller.settings;
    return Chapter5Hero(
      eyebrow: 'Task 14  •  Background worker',
      title: 'Thời tiết luôn mới.',
      description: 'Tự đồng bộ dữ liệu từ OpenWeather, lưu bản gần nhất và cảnh báo nóng theo ngưỡng.',
      icon: Icons.wb_sunny_outlined,
      from: const Color(0xFF78451F),
      to: const Color(0xFFEE8F35),
      status: settings.workerEnabled ? 'Worker đang đăng ký' : 'Worker chưa đăng ký',
      detail: '${settings.city.label}  •  ${settings.intervalMinutes} phút',
    );
  }


  Widget _settingsTab() {
    final settings =
        controller.settings;

    const intervals =
        [15, 30, 60, 180, 360];

    return _list([
      _chapterOverview(),
      const SizedBox(height: 17),
      WeatherPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cấu hình đồng bộ nền',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'WorkManager • '
                        'Background Isolate',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  settings.workerEnabled
                      ? Icons
                          .check_circle
                      : Icons
                          .pause_circle_outline,
                  color:
                      settings.workerEnabled
                          ? weatherOrange
                          : Colors.black38,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.all(11),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF4F3F7,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color:
                        weatherOrange,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lịch đồng bộ chạy theo điều kiện hệ thống. '
                      'Để xem kết quả ngay, hãy dùng nút Đồng bộ ngay ở tab Thời tiết.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      WeatherPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Chu kỳ đồng bộ',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Khoảng cách tối thiểu 15 phút; Android có thể chạy trễ hơn.',
              style: TextStyle(
                fontSize: 11,
                color:
                    Colors.black45,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children:
                  intervals.map(
                (minutes) {
                  final selected =
                      settings
                              .intervalMinutes ==
                          minutes;

                  final label =
                      minutes < 60
                          ? '${minutes}p'
                          : '${minutes ~/ 60}h';

                  return ChoiceChip(
                    selected:
                        selected,
                    label:
                        Text(label),
                    selectedColor:
                        weatherSoftOrange,
                    labelStyle:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      color: selected
                          ? weatherDarkOrange
                          : Colors.black54,
                    ),
                    onSelected: (_) {
                      controller
                          .setInterval(
                        minutes,
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


      WeatherPanel(
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          leading: const Icon(Icons.tune_rounded, color: weatherOrange),
          title: const Text(
            'Điều kiện chạy nền (nâng cao)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'Tiết kiệm pin và dữ liệu; có thể khiến lần đồng bộ bị hoãn.',
            style: TextStyle(fontSize: 12),
          ),
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.wifi_rounded, color: weatherOrange),
              title: const Text('Chỉ dùng mạng không tính phí dữ liệu'),
              subtitle: const Text('Thường là Wi-Fi; dữ liệu di động có thể không được dùng.'),
              value: settings.wifiOnly,
              onChanged: controller.setWifiOnly,
            ),
            const Divider(height: 1),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.battery_charging_full_rounded, color: weatherOrange),
              title: const Text('Đợi đến khi đang sạc'),
              subtitle: const Text('Chỉ cho phép worker chạy khi máy cắm sạc.'),
              value: settings.chargingOnly,
              onChanged: controller.setChargingOnly,
            ),
            const Divider(height: 1),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.battery_saver_outlined, color: weatherOrange),
              title: const Text('Tránh chạy khi pin yếu'),
              subtitle: const Text('Để Android tự xác định ngưỡng pin thấp.'),
              value: settings.batteryNotLow,
              onChanged: controller.setBatteryNotLow,
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      WeatherPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Thành phố đồng bộ',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  WeatherCity.all.map(
                (city) {
                  return ChoiceChip(
                    selected:
                        settings.cityKey ==
                            city.key,
                    label:
                        Text(city.label),
                    selectedColor:
                        weatherSoftOrange,
                    onSelected: (_) {
                      controller
                          .setCity(
                        city.key,
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

      WeatherPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,
              title:
                  const Text(
                'Cảnh báo nhiệt độ',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              subtitle:
                  const Text(
                'Bonus +2 • Ngưỡng tùy chỉnh',
              ),
              value:
                  settings.alertEnabled,
              onChanged:
                  controller
                      .setAlertEnabled,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                const Text(
                  'Ngưỡng kích hoạt',
                ),
                Text(
                  '${settings.thresholdC.toStringAsFixed(0)}°C',
                  style:
                      const TextStyle(
                    color:
                        weatherOrange,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            Slider(
              min: 20,
              max: 45,
              divisions: 25,
              value:
                  settings.thresholdC,
              activeColor:
                  weatherOrange,
              onChanged: (value) {
                controller
                    .setThreshold(value);
              },
            ),
            const Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  '20°C',
                  style:
                      TextStyle(
                    fontSize: 11,
                  ),
                ),
                Text(
                  '45°C',
                  style:
                      TextStyle(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      const SizedBox(height: 18),

      SizedBox(
        height: 52,
        child: FilledButton.icon(
          style:
              FilledButton.styleFrom(
            backgroundColor:
                weatherOrange,
          ),
          onPressed: () async {
            if (settings.workerEnabled) {
              await controller
                  .cancelWorker();
            } else {
              await controller
                  .registerWorker();
            }

            if (!mounted) return;

            if (controller.feedback !=
                null) {
              _snack(
                controller.feedback!,
              );
            }
          },
          icon: Icon(
            settings.workerEnabled
                ? Icons.stop_circle
                : Icons.schedule_send,
          ),
          label: Text(
            settings.workerEnabled
                ? 'Tắt Background Worker'
                : 'Đăng ký Background Worker',
          ),
        ),
      ),

      const SizedBox(height: 8),

      SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed:
              controller.status ==
                      WeatherSyncStatus
                          .syncing
                  ? null
                  : () async {
                      await controller
                          .testOneOffWorker();

                      if (!mounted) {
                        return;
                      }

                      if (controller
                              .feedback !=
                          null) {
                        _snack(
                          controller
                              .feedback!,
                        );
                      }
                    },
          icon:
              controller.status ==
                      WeatherSyncStatus
                          .syncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.bolt,
                    ),
          label: const Text(
            'Chạy thử One-off Worker',
          ),
        ),
      ),
    ]);
  }


  Widget _weatherTab() {
    final snapshot =
        controller.selectedSnapshot;

    return _list([
      WeatherPanel(
        child: Row(
          children: [
            Icon(
              snapshot != null
                  ? Icons.check_circle
                  : Icons.cloud_off,
              color:
                  snapshot != null
                      ? weatherOrange
                      : Colors.black38,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: snapshot == null
                  ? const Text(
                      'Chưa có dữ liệu '
                      'thời tiết trong Hive.',
                    )
                  : Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'Lần đồng bộ gần nhất',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Colors.black45,
                          ),
                        ),
                        Text(
                          '${_time(snapshot.syncedAt)} '
                          '• ${snapshot.source}',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
            IconButton(
              onPressed:
                  controller.syncNow,
              icon:
                  const Icon(
                Icons.refresh,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      if (snapshot == null)
        WeatherPanel(
          child: Column(
            children: [
              const Icon(
                Icons.cloud_outlined,
                size: 52,
                color:
                    Colors.black26,
              ),
              const SizedBox(height: 10),
              const Text(
                'Chưa có snapshot',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed:
                    controller.syncNow,
                child:
                    const Text(
                  'Đồng bộ ngay',
                ),
              ),
            ],
          ),
        )
      else
        _weatherHero(snapshot),

      if (controller.lastError !=
          null) ...[
        const SizedBox(height: 14),
        WeatherPanel(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.cloud_off,
                    color:
                        Colors.redAccent,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sync gần nhất gặp lỗi',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                controller.lastError!,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width:
                    double.infinity,
                child:
                    FilledButton.icon(
                  onPressed:
                      controller.syncNow,
                  icon:
                      const Icon(
                    Icons.replay,
                  ),
                  label:
                      const Text(
                    'Thử lại ngay',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      const SizedBox(height: 14),

      _cachedCities(),

      const SizedBox(height: 14),

      WeatherPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Cập nhật tự động theo lịch',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            _infoRow(
              'Task',
              'task14_weather_periodic',
            ),
            _infoRow(
              'Chu kỳ',
              '${controller.settings.intervalMinutes} phút',
            ),
            _infoRow(
              'Cache',
              'Hive • task14_weather_cache_box',
            ),
            _infoRow(
              'Retry',
              'WorkManager exponential backoff',
            ),
          ],
        ),
      ),
    ]);
  }

  // Thẻ nhiệt độ nổi bật, lấy giá trị từ WeatherSnapshot thay vì hardcode UI.
  Widget _weatherHero(
    WeatherSnapshot snapshot,
  ) {
    final over =
        snapshot.temperature >
            controller
                .settings.thresholdC;

    return WeatherPanel(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color:
                    weatherOrange,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  controller
                      .settings.city.label,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Text(
                'OpenWeather',
                style: TextStyle(
                  fontSize: 11,
                  color:
                      Colors.black45,
                ),
              ),
            ],
          ),

          if (over) ...[
            const SizedBox(height: 12),
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                11,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFFFE4DF,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Text(
                '⚠️ ${snapshot.temperature.toStringAsFixed(1)}°C '
                'đã vượt ngưỡng '
                '${controller.settings.thresholdC.toStringAsFixed(0)}°C',
                style:
                    const TextStyle(
                  color:
                      Colors.redAccent,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      '${snapshot.temperature.toStringAsFixed(1)}°',
                      style:
                          const TextStyle(
                        color:
                            weatherOrange,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 48,
                        letterSpacing:
                            -2,
                      ),
                    ),
                    Text(
                      snapshot.description,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Cảm giác '
                      '${snapshot.feelsLike.toStringAsFixed(1)}°C',
                      style:
                          const TextStyle(
                        color:
                            Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 43,
                backgroundColor:
                    weatherSoftOrange,
                child: Icon(
                  Icons.wb_sunny,
                  size: 45,
                  color:
                      weatherOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              WeatherMetric(
                icon:
                    Icons.water_drop_outlined,
                label:
                    'Độ ẩm',
                value:
                    '${snapshot.humidity}%',
              ),
              const SizedBox(width: 7),
              WeatherMetric(
                icon:
                    Icons.air,
                label: 'Gió',
                value:
                    '${snapshot.windKph.toStringAsFixed(1)} km/h',
              ),
              const SizedBox(width: 7),
              WeatherMetric(
                icon:
                    Icons.speed,
                label:
                    'Áp suất',
                value:
                    '${snapshot.pressure} hPa',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Danh sách thành phố đã cache; hữu ích khi mất mạng hoặc cần so sánh lần cập nhật.
  Widget _cachedCities() {
    return WeatherPanel(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Dữ liệu trong Hive',
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (controller
              .snapshots.isEmpty)
            const Text(
              'Chưa có dữ liệu cache.',
              style: TextStyle(
                color:
                    Colors.black45,
              ),
            )
          else
            ...controller
                .snapshots.values
                .map(
              (item) {
                return ListTile(
                  contentPadding:
                      EdgeInsets.zero,
                  leading:
                      const CircleAvatar(
                    backgroundColor:
                        weatherSoftOrange,
                    child: Icon(
                      Icons.cloud,
                      color:
                          weatherOrange,
                    ),
                  ),
                  title: Text(
                    WeatherCity
                        .byKey(
                          item.cityKey,
                        )
                        .label,
                  ),
                  subtitle: Text(
                    '${item.description} • '
                    '${_time(item.syncedAt)}',
                  ),
                  trailing: Text(
                    '${item.temperature.toStringAsFixed(1)}°C',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }


  Widget _alertsTab() {
    final snapshot =
        controller.selectedSnapshot;

    final threshold =
        controller.settings.thresholdC;

    final over =
        snapshot != null &&
            snapshot.temperature >
                threshold;

    final alerts = controller.history
        .where(
          (e) =>
              e.type == 'alert',
        )
        .toList();

    return _list([
      Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: over
              ? weatherOrange
              : Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 37,
              backgroundColor:
                  over
                      ? Colors.white24
                      : weatherSoftOrange,
              child: Icon(
                over
                    ? Icons.warning_rounded
                    : Icons
                        .verified_outlined,
                color: over
                    ? Colors.white
                    : weatherOrange,
                size: 38,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              over
                  ? 'Nhiệt độ vượt ngưỡng'
                  : 'Nhiệt độ bình thường',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color: over
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              snapshot == null
                  ? 'Chưa có dữ liệu thời tiết.'
                  : '${snapshot.temperature.toStringAsFixed(1)}°C '
                      '• Ngưỡng '
                      '${threshold.toStringAsFixed(0)}°C',
              style: TextStyle(
                color: over
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      WeatherPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Quy tắc thông báo',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _rule(
              Icons.thermostat,
              'Điều kiện',
              'Nhiệt độ > '
                  '${threshold.toStringAsFixed(0)}°C',
            ),
            _rule(
              Icons
                  .notifications_active_outlined,
              'Notification',
              'High priority • âm thanh • rung',
            ),
            _rule(
              Icons.timer_outlined,
              'Chống spam',
              'Tối đa 1 cảnh báo / 2 giờ',
            ),
          ],
        ),
      ),

      const SizedBox(height: 14),

      WeatherPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Cảnh báo gần đây',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            if (alerts.isEmpty)
              const Text(
                'Chưa có cảnh báo nhiệt độ.',
                style: TextStyle(
                  color:
                      Colors.black45,
                ),
              )
            else
              ...alerts.take(10).map(
                    _eventTile,
                  ),
          ],
        ),
      ),
    ]);
  }


  Widget _historyTab() {
    return _list([
      WeatherPanel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch sử Worker',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tối đa 50 sự kiện gần nhất',
              style: TextStyle(
                fontSize: 11,
                color:
                    Colors.black45,
              ),
            ),
            const SizedBox(height: 12),
            if (controller.history.isEmpty)
              const Center(
                child: Padding(
                  padding:
                      EdgeInsets.all(20),
                  child: Text(
                    'Chưa có lịch sử.',
                  ),
                ),
              )
            else
              ...controller.history
                  .map(_eventTile),
          ],
        ),
      ),
    ]);
  }

  //1 dòng sự kiện đồng bộ với trạng thái và thời gian
  Widget _eventTile(
    WeatherSyncEvent event,
  ) {
    IconData icon;

    if (event.type == 'alert') {
      icon =
          Icons.notifications_active;
    } else if (!event.success) {
      icon =
          Icons.error_outline;
    } else if (event.type ==
        'worker') {
      icon =
          Icons.settings_backup_restore;
    } else {
      icon =
          Icons.cloud_done_outlined;
    }

    return ListTile(
      contentPadding:
          EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            event.success
                ? weatherSoftOrange
                : const Color(
                    0xFFFFE2DE,
                  ),
        child: Icon(
          icon,
          color:
              event.success
                  ? weatherOrange
                  : Colors.redAccent,
          size: 20,
        ),
      ),
      title: Text(
        event.message,
        style:
            const TextStyle(
          fontSize: 13,
          fontWeight:
              FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _time(event.createdAt),
      ),
    );
  }


  Widget _rule(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return ListTile(
      contentPadding:
          EdgeInsets.zero,
      leading: Icon(
        icon,
        color: weatherOrange,
      ),
      title:
          Text(title),
      subtitle:
          Text(subtitle),
    );
  }


  Widget _infoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Text(
            title,
            style:
                const TextStyle(
              color:
                  Colors.black45,
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
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}