

import 'package:flutter/material.dart';

const newsRed =
    Color(0xFFBE3E4F);

const newsDarkRed =
    Color(0xFF852F43);

const newsSoftRed =
    Color(0xFFFFE2E2);

const newsBackground =
    Color(0xFFFFF8F7);


class NewsPanel
    extends StatelessWidget {
  const NewsPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
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
                Color(0x0C000000),
            blurRadius: 15,
            offset:
                Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ô số liệu thống kê số tin, bookmark, phiên sync lấy từ controller
class NewsStatCard
    extends StatelessWidget {
  const NewsStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Expanded(
      child: NewsPanel(
        padding:
            const EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  newsSoftRed,
              child: Icon(
                icon,
                color: newsRed,
                size: 18,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              value,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              label,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}