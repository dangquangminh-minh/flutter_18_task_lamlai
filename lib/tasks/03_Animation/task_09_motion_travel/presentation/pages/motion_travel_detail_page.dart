

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/repositories/motion_travel_repository.dart';
import '../../domain/models/travel_country.dart';
import '../../domain/models/travel_weather.dart';

class MotionTravelDetailPage extends StatefulWidget {
  const MotionTravelDetailPage({
    super.key,
    required this.country,
    required this.heroUrl,
    required this.repository,
  });

  final TravelCountry country;
  final String? heroUrl;
  final MotionTravelRepository repository;

  @override
  State<MotionTravelDetailPage> createState() =>
      _MotionTravelDetailPageState();
}

class _MotionTravelDetailPageState
    extends State<MotionTravelDetailPage> {
  late Future<TravelWeather> weatherFuture;

  double scrollOffset = 0;

  static const red = Color(0xFFB70011);

  @override
  void initState() {
    super.initState();

    weatherFuture =
        widget.repository.getWeather(widget.country);
  }

  void retryWeather() {
    setState(() {
      weatherFuture =
          widget.repository.getWeather(widget.country);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (!reduceMotion &&
              notification.metrics.axis == Axis.vertical) {
            setState(() {
              scrollOffset =
                  notification.metrics.pixels.clamp(0, 400);
            });
          }

          return false;
        },
        child: CustomScrollView(
          slivers: [
            _appBar(reduceMotion),

            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _offlineBadge(),

                    const SizedBox(height: 22),

                    _sectionTitle(
                      Icons.thermostat,
                      'Khí hậu & Thời tiết thời gian thực',
                    ),

                    const SizedBox(height: 10),

                    _weatherCard(reduceMotion),

                    const SizedBox(height: 24),

                    _sectionTitle(
                      Icons.public,
                      'Thông số Quốc gia',
                    ),

                    const SizedBox(height: 10),

                    _countryGrid(reduceMotion),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBar(bool reduceMotion) {
    final imageUrl =
        widget.heroUrl ?? widget.country.flagUrl;

    final parallaxY =
        reduceMotion ? 0.0 : scrollOffset * .28;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 340,
      backgroundColor: const Color(0xFF191C1E),
      foregroundColor: Colors.white,
      title: Text(widget.country.name),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(0, parallaxY),
              child: Transform.scale(
                scale: 1.12,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) {
                    return Container(
                      color: const Color(0xFFE0E3E5),
                      child: const Icon(
                        Icons.public,
                        size: 70,
                      ),
                    );
                  },
                ),
              ),
            ),

            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x55000000),
                    Colors.transparent,
                    Color(0xDD191C1E),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.country.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    widget.country.officialName,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  if (!reduceMotion) ...[
                    const SizedBox(height: 9),
                    const Row(
                      children: [
                        Icon(
                          Icons.keyboard_double_arrow_down,
                          color: Colors.white70,
                          size: 17,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'CUỘN ĐỂ CẢM NHẬN PARALLAX',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: .8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _offlineBadge() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFECEEF0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.offline_pin,
            color: red,
            size: 19,
          ),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Thông tin quốc gia có thể được đọc từ Hive cache.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(icon, color: red),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _weatherCard(bool reduceMotion) {
    return FutureBuilder<TravelWeather>(
      future: weatherFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Container(
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E8EA),
              borderRadius: BorderRadius.circular(20),
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(),
              )
              .shimmer(
                duration: reduceMotion ? 1.ms : 1200.ms,
                color: Colors.white54,
              );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_off,
                  color: red,
                  size: 36,
                ),
                const SizedBox(height: 7),
                const Text(
                  'Không tải được thời tiết.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: retryWeather,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final weather = snapshot.data!;

        final card = Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  if (weather.iconUrl.isNotEmpty)
                    Image.network(
                      weather.iconUrl,
                      width: 70,
                      height: 70,
                    ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.temperature.round()}°C',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          weather.description,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    'Cảm giác\n${weather.feelsLike.round()}°C',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _metric(
                      Icons.water_drop_outlined,
                      'Độ ẩm',
                      '${weather.humidity}%',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _metric(
                      Icons.air,
                      'Sức gió',
                      '${weather.windKmh.toStringAsFixed(1)} km/h',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        if (reduceMotion) return card;

        return card
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(
              begin: .08,
              end: 0,
              duration: 450.ms,
            );
      },
    );
  }

  Widget _metric(
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(icon, color: red, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _countryGrid(bool reduceMotion) {
    final country = widget.country;

    final cards = [
      _infoCard(
        Icons.location_city,
        'Thủ đô',
        country.capital,
      ),
      _infoCard(
        Icons.groups_outlined,
        'Dân số',
        _population(country.population),
      ),
      _infoCard(
        Icons.payments_outlined,
        'Tiền tệ',
        country.currency,
      ),
      _infoCard(
        Icons.translate,
        'Ngôn ngữ',
        country.languages,
      ),
      _infoCard(
        Icons.schedule,
        'Múi giờ',
        country.timezone,
      ),
      _infoCard(
        Icons.map_outlined,
        'Khu vực',
        country.subregion,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.45,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
      ),
      itemBuilder: (_, index) {
        if (reduceMotion) return cards[index];

        return cards[index]
            .animate(
              delay: Duration(
                milliseconds: index * 70,
              ),
            )
            .fadeIn(duration: 350.ms)
            .slideY(
              begin: .12,
              end: 0,
              duration: 350.ms,
            );
      },
    );
  }

  Widget _infoCard(
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: red, size: 21),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _population(int value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} tỷ';
    }

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} triệu';
    }

    return '$value';
  }
}