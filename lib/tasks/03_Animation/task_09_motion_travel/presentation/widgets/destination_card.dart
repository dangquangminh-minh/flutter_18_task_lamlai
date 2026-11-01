

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../pages/motion_travel_detail_page.dart';

import '../../data/repositories/motion_travel_repository.dart';

import '../../domain/models/travel_country.dart';


class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.country,
    required this.heroUrl,
    required this.repository,
    required this.reduceMotion,
  });

  final TravelCountry country;
  final String? heroUrl;
  final MotionTravelRepository repository;
  final bool reduceMotion;

  static const red = Color(0xFFB70011);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 480),
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: const Color(0xFFF7F9FB),
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      closedBuilder: (context, openContainer) {
        return GestureDetector(
          onTap: openContainer,
          child: Container(
            height: 255,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x17000000),
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _image(),

                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x15000000),
                          Color(0x25000000),
                          Color(0xDD191C1E),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .55),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: red,
                            child: Text(
                              country.cca2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            country.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (heroUrl == null)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .88),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Ảnh cờ dự phòng',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: red,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                country.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Thủ đô: ${country.capital}'
                                ' • ${country.subregion}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const CircleAvatar(
                          backgroundColor: red,
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      openBuilder: (_, _) {
        return MotionTravelDetailPage(
          country: country,
          heroUrl: heroUrl,
          repository: repository,
        );
      },
    );
  }

  Widget _image() {
    final url = heroUrl ?? country.flagUrl;

    if (url.isEmpty) {
      return Container(
        color: const Color(0xFFE0E3E5),
        child: const Icon(
          Icons.public,
          size: 70,
          color: red,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) {
        return Container(
          color: const Color(0xFFE0E3E5),
        );
      },
      errorWidget: (_, _, _) {
        return Container(
          color: const Color(0xFFE0E3E5),
          child: const Icon(Icons.public),
        );
      },
    );
  }
}