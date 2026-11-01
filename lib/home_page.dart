
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router/app_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const primary = Color(0xFF245D85);

  Widget _taskCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text(
          'Flutter Practice',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FLUTTER LEARNING JOURNEY',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFC7E4F8),
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 9),
                  Text(
                    '18 Flutter Tasks',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Thực hành Flutter từ cơ bản đến nâng cao.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // chương 1
            const Text(
              'CHƯƠNG 1 - STATE MANAGEMENT (BLOC)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 15),

            _taskCard(
              context: context,
              title: 'Bài 01 - Mini Cart',
              subtitle: 'Quản lý giỏ hàng bằng BLoC',
              icon: Icons.shopping_cart_rounded,
              color: const Color(0xFF238653),
              route: AppRoutes.task01,
            ),

            _taskCard(
              context: context,
              title: 'Bài 02 - News Filter Hub',
              subtitle: 'Tìm kiếm, lọc và phân trang tin tức',
              icon: Icons.newspaper_rounded,
              color: const Color(0xFFF26B0A),
              route: AppRoutes.task02,
            ),

            _taskCard(
              context: context,
              title: 'Bài 03 - Travel Planner Pro',
              subtitle: 'Multi BLoC, thời tiết và dữ liệu offline',
              icon: Icons.travel_explore_rounded,
              color: const Color(0xFFC62828),
              route: AppRoutes.task03,
            ),

            const SizedBox(height: 24),


            //chương 2

            const Text(
              'CHƯƠNG 2 - REST API INTEGRATION',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 15),

            _taskCard(
              context: context,
              title: 'Bài 04 - Country Explorer',
              subtitle: 'Danh bạ quốc gia, tìm kiếm và sắp xếp dân số',
              icon: Icons.public_rounded,
              color: const Color(0xFF158C82),
              route: AppRoutes.task04,
            ),

            _taskCard(
              context: context,
              title: 'Bài 05 - Weather Lens',
              subtitle: 'Thời tiết hiện tại và dự báo theo ngày',
              icon: Icons.wb_sunny_outlined,
              color: const Color(0xFF147EBC),
              route: AppRoutes.task05,
            ),

            _taskCard(
              context: context,
              title: 'Bài 06 - Visual Newsroom',
              subtitle: 'Tin tức hình ảnh, SQLite và bookmark offline',
              icon: Icons.auto_stories_rounded,
              color: const Color(0xFF29364D),
              route: AppRoutes.task06,
            ),

            // chương 3
            const SizedBox(height: 24),
            const Text(
              'CHƯƠNG 3 - ANIMATION',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 15),
            _taskCard(
              context: context,
              title: 'Bài 07 - Mood Cards',
              subtitle: 'Thẻ hoạt động, yêu thích và hiệu ứng chuyển động',
              icon: Icons.favorite_rounded,
              color: const Color(0xFF2E7D32),
              route: AppRoutes.task07,
            ),


            _taskCard(
              context: context,
              title: 'Bài 08 - Photo Stories',
              subtitle: 'Thư viện ảnh, bộ lọc và Hero Animation',
              icon: Icons.photo_library_rounded,
              color: const Color(0xFFF26B0A),
              route: AppRoutes.task08,
            ),

            _taskCard(
              context: context,
              title: 'Bài 09 - Motion Travel',
              subtitle: 'Khám phá du lịch, thời tiết và chuyển cảnh',
              icon: Icons.flight_takeoff_rounded,
              color: const Color(0xFFC62828),
              route: AppRoutes.task09,
            ),
          ],
        ),
      ),
    );
  }
}
