

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/models/pixabay_photo.dart';

class PhotoGridCard extends StatelessWidget {
  const PhotoGridCard({
    super.key,
    required this.photo,
    required this.onTap,
    this.spotlight = false,
  });

  final PixabayPhoto photo;
  final VoidCallback onTap;
  final bool spotlight;

  static const orange = Color(0xFFA33900);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: const Color(0xFFE8E8E7),
          child: AspectRatio(
            aspectRatio: photo.aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'pixabay_${photo.id}',
                  child: CachedNetworkImage(
                    imageUrl: photo.webformatUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) {
                      return Container(
                        color: const Color(0xFFE8E8E7),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: orange,
                          ),
                        ),
                      );
                    },
                    errorWidget: (_, _, _) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 34,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),

                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.35, 1],
                        colors: [
                          Colors.transparent,
                          Color(0xCC1F1F1F),
                        ],
                      ),
                    ),
                  ),
                ),

                if (spotlight)
                  Positioned(
                    top: 9,
                    left: 9,
                    child: _badge(
                      Icons.motion_photos_on,
                      'Hero',
                    ),
                  ),

                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .88),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          size: 13,
                          color: orange,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _compact(photo.likes),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: 11,
                  right: 11,
                  bottom: 11,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '@${photo.user}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: orange),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              color: orange,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _compact(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }

    return '$value';
  }
}