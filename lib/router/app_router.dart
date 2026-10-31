import 'package:go_router/go_router.dart';

import '../home_page.dart';
import '../tasks/01_State Management(BLoC)/task_01_mini_cart/screens/cart_page.dart';
import '../tasks/01_State Management(BLoC)/task_02_news_filter/screens/news_page.dart';
import '../tasks/01_State Management(BLoC)/task_03_travel_planner/presentation/pages/travel_entry_page.dart';

// Lưu các đường dẫn tại một nơi để tránh viết sai khi điều hướng.
// Khi thêm Task mới, khai báo hằng route và GoRoute tương ứng ở đây.
class AppRoutes {
  static const home = '/';
  static const task01 = '/task-01';
  static const task02 = '/task-02';
  static const task03 = '/task-03';
}

// Router chỉ quyết định màn hình cần mở.
// BlocProvider của mỗi Task vẫn được tạo tại màn hình của Task đó.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.task01,
      name: 'task01',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: AppRoutes.task02,
      name: 'task02',
      builder: (context, state) => const NewsPage(),
    ),
    GoRoute(
      path: AppRoutes.task03,
      name: 'task03',
      // Trang entry sẽ khởi tạo Hive, DI và MultiBlocProvider cho Bài 3.
      builder: (context, state) => const TravelEntryPage(),
    ),
  ],
);
