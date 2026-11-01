

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1, end: 1.35),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 1),
        weight: 55,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

// phản hồi chạm kết hợp scale animation
  Future<void> _tap() async {
    HapticFeedback.lightImpact();

    widget.onPressed();

    await _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: IconButton(
        onPressed: _tap,
        style: IconButton.styleFrom(
          backgroundColor: widget.isFavorite
              ? const Color(0xFFFFDAD6)
              : const Color(0xFFE7F0E6),
        ),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Icon(
            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(widget.isFavorite),
            color: widget.isFavorite
                ? Colors.red
                : const Color(0xFF00652C),
          ),
        ),
      ),
    );
  }
}