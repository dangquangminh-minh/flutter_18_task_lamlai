

import 'package:flutter/material.dart';

class Chapter5Hero extends StatelessWidget {
  const Chapter5Hero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    
    required this.from,
    required this.to,
    required this.status,
    this.detail,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Color from;
  final Color to;
  final String status;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [from, to],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: from.withValues(alpha: 0.19),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -64,
            right: -62,
            child: Container(
              width: 205,
              height: 205,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.13),
                  width: 32,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        eyebrow.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.80),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 27),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                    height: 1.12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(text: status, emphasized: true),
                    if (detail != null && detail!.isNotEmpty)
                      _Pill(text: detail!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.emphasized = false});

  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: emphasized ? 0.22 : 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
