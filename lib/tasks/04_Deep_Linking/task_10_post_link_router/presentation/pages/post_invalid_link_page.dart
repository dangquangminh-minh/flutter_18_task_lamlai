

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostInvalidLinkPage extends StatelessWidget {
  const PostInvalidLinkPage({
    super.key,
    required this.uri,
    required this.message,
    this.onRetry,
  });

  final String uri;
  final String message;
  // retry khi api gặp trục trặc
  final Future<void> Function()? onRetry;

  static const green = Color(0xFF0E8D7F);
  static const background = Color(0xFFF4F7F5);

  @override
  // trag lỗi cũng là một route chính thức
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Liên kết không hợp lệ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 30),

            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBF4EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.link_off_rounded,
                  color: Color(0xFF0E8D7F),
                  size: 46,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Không mở được liên kết',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Liên kết đã nhận',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  SelectableText(
                    uri.isEmpty ? 'Không xác định' : uri,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: green,
                      ),
                      SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Định dạng đúng: '
                          'myapp://post/{id}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (onRetry != null) ...[
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: green,
                  ),
                  onPressed: () async {
                    await onRetry!();
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: const Text(
                    'Thử lại truy vấn',
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.go(
                    '/task_10_post_link_router',
                  );
                },
                icon: const Icon(
                  Icons.home_outlined,
                ),
                label: const Text(
                  'Quay về danh sách',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}