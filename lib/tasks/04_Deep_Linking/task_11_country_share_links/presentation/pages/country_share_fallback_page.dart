

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CountryShareFallbackPage
    extends StatelessWidget {
  const CountryShareFallbackPage({
    super.key,
    required this.attemptedLink,
    required this.message,
  });



  final String attemptedLink;
  final String message;

  static const orange = Color(0xFF6354C7);
  static const background = Color(0xFFF6F5FB);

  @override
  // đưa link mẫu đúng
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor:
            Colors.transparent,
        title: const Text(
          'Liên Kết Không Hợp Lệ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 18),

            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFDAD6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.link_off_rounded,
                  size: 48,
                  color: Color(0xFFBA1A1A),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Không mở được liên kết',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Liên kết đã nhận',
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    attemptedLink.isEmpty
                        ? 'Không xác định'
                        : attemptedLink,
                    style: const TextStyle(
                      color: orange,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: FilledButton.icon(
                style:
                    FilledButton.styleFrom(
                  backgroundColor: orange,
                ),
                onPressed: () {
                  context.go(
                    '/countries?region=Asia',
                  );
                },
                icon: const Icon(
                  Icons.public,
                ),
                label: const Text(
                  'Quay về danh sách quốc gia',
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Thử liên kết hợp lệ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _preset(
              context,
              icon: Icons.flag,
              title: 'Việt Nam',
              subtitle: 'myapp://country/VNM',
              route: '/country/VNM',
            ),

            _preset(
              context,
              icon: Icons.map,
              title: 'Nhật Bản',
              subtitle: 'myapp://country/JPN',
              route: '/country/JPN',
            ),

            _preset(
              context,
              icon: Icons.travel_explore,
              title: 'Châu Á',
              subtitle:
                  'myapp://countries?region=Asia',
              route:
                  '/countries?region=Asia',
            ),
          ],
        ),
      ),
    );
  }

  Widget _preset(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: () {
          context.go(route);
        },
        leading: CircleAvatar(
          backgroundColor:
              const Color(0xFFFFDBCE),
          child: Icon(
            icon,
            color: orange,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }
}