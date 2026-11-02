

import 'package:flutter/material.dart';

const reminderGreen =
    Color(0xFF23795B);

const reminderDarkGreen =
    Color(0xFF124E42);

const reminderBackground =
    Color(0xFFF3F8F5);

const reminderSoftGreen =
    Color(0xFFDDF3E7);

// card trình bày dùng chung
class ReminderCard
    extends StatelessWidget {
  const ReminderCard({
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
            color: Color(0x130F5842),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}