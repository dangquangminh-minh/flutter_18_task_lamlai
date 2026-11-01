import 'package:go_router/go_router.dart';

import '../home_page.dart';
import '../tasks/02_REST_API_Integration/task_04_country_explorer/presentation/pages/country_list_page.dart';
import '../tasks/02_REST_API_Integration/task_05_weather_lens/presentation/pages/weather_page.dart';
import '../tasks/02_REST_API_Integration/task_06_visual_newsroom/presentation/pages/visual_news_entry_page.dart';
import '../tasks/01_State Management(BLoC)/task_01_mini_cart/screens/cart_page.dart';
import '../tasks/01_State Management(BLoC)/task_02_news_filter/screens/news_page.dart';
import '../tasks/01_State Management(BLoC)/task_03_travel_planner/presentation/pages/travel_entry_page.dart';


class AppRoutes {
  static const home = '/';
  static const task01 = '/task-01';
  static const task02 = '/task-02';
  static const task03 = '/task-03';
  static const task04 = '/task-04';
  static const task05 = '/task-05';
  static const task06 = '/task-06';
}


final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),




    //chương 1
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

      builder: (context, state) => const TravelEntryPage(),
    ),




    //Chương 2
    GoRoute(path: AppRoutes.task04, name: 'task04',
        builder: (context, state) => const CountryListPage()),
    GoRoute(path: AppRoutes.task05, name: 'task05',
        builder: (context, state) => const WeatherPage()),
    GoRoute(path: AppRoutes.task06, name: 'task06',
        builder: (context, state) => const VisualNewsEntryPage()),
  ],
);
