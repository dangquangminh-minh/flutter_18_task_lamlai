

import 'package:flutter/material.dart';


class ActivityVisuals {
  static const Map<String, (Color, Color, IconData)> _styles = {
    'education': (Color(0xFF5478D4), Color(0xFF9FB6F2), Icons.menu_book_rounded),
    'recreational': (Color(0xFF188B79), Color(0xFF88D9B8), Icons.park_rounded),
    'recreation': (Color(0xFF188B79), Color(0xFF88D9B8), Icons.park_rounded),
    'social': (Color(0xFFCC6A76), Color(0xFFFFBCC6), Icons.groups_rounded),
    'cooking': (Color(0xFFD1843A), Color(0xFFFFCE93), Icons.restaurant_rounded),
    'relaxation': (Color(0xFF8875C4), Color(0xFFD5C7FC), Icons.self_improvement_rounded),
    'charity': (Color(0xFFCD6086), Color(0xFFF7B4CD), Icons.volunteer_activism_rounded),
    'diy': (Color(0xFF4F92AB), Color(0xFFA2DEEC), Icons.handyman_rounded),
  };

  static (Color, Color, IconData) style(String type) =>
      _styles[type] ?? (const Color(0xFF288771), const Color(0xFF95D9C9), Icons.auto_awesome_rounded);

  static IconData icon(String type) => style(type).$3;

  static Widget cover(String type, {double height = 164}) {
    final palette = style(type);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [palette.$1, palette.$2]),
        ),
        child: Stack(children: [
          Positioned(top: -48, right: -34,
            child: Container(width: 185, height: 185,
              decoration: BoxDecoration(shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: .20), width: 24)))),
          Positioned(bottom: -62, left: -45,
            child: Container(width: 150, height: 150,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .10)))),
          Center(child: Container(
            width: 92, height: 92,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18),
              border: Border.all(color: Colors.white.withValues(alpha: .45)),
              borderRadius: BorderRadius.circular(28)),
            child: Icon(palette.$3, color: Colors.white, size: 48),
          )),
        ]),
      ),
    );
  }
}
