

import 'package:flutter/material.dart';

const weatherOrange =
    Color(0xFFF28A2A);

const weatherDarkOrange =
    Color(0xFFAB4A1B);

const weatherBackground =
    Color(0xFFFFF9F0);

const weatherSoftOrange =
    Color(0xFFFFE9D0);


class WeatherPanel
    extends StatelessWidget {
  const WeatherPanel({
    super.key,
    required this.child,
    this.padding =
        const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x16B56F2C),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ô hiển thị nhiệt độ, độ ẩm, tốc độ gió
class WeatherMetric
    extends StatelessWidget {
  const WeatherMetric({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color:
              const Color(0xFFF4F3F7),
          borderRadius:
              BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: weatherOrange,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}