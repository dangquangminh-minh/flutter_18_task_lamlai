import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// sửa lỗi test bài 12 mà k quay về homepage đc
class Chapter4BackScope extends StatelessWidget {
  const Chapter4BackScope({
    super.key,
    required this.fallbackPath,
    required this.child,
  });

  final String fallbackPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {

        if (!didPop && context.mounted) {
          context.go(fallbackPath);
        }
      },
      child: child,
    );
  }
}