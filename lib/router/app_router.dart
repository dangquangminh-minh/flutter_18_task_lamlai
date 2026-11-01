import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../home_page.dart';

// chương 1
import '../tasks/01_State Management(BLoC)/task_01_mini_cart/screens/cart_page.dart';
import '../tasks/01_State Management(BLoC)/task_02_news_filter/screens/news_page.dart';
import '../tasks/01_State Management(BLoC)/task_03_travel_planner/presentation/pages/travel_entry_page.dart';

// chương 2
import '../tasks/02_REST_API_Integration/task_04_country_explorer/presentation/pages/country_list_page.dart';
import '../tasks/02_REST_API_Integration/task_05_weather_lens/presentation/pages/weather_page.dart';
import '../tasks/02_REST_API_Integration/task_06_visual_newsroom/presentation/pages/visual_news_entry_page.dart';

//chương 3, bài 7:
import '../tasks/03_Animation/task_07_mood_cards/data/datasources/activity_remote_data_source.dart';
import '../tasks/03_Animation/task_07_mood_cards/data/repositories/activity_repository.dart';
import '../tasks/03_Animation/task_07_mood_cards/presentation/pages/mood_cards_page.dart';

//chương 3, bài 8
import '../tasks/03_Animation/task_08_photo_stories/data/datasources/pixabay_remote_data_source.dart';
import '../tasks/03_Animation/task_08_photo_stories/data/repositories/photo_repository.dart';
import '../tasks/03_Animation/task_08_photo_stories/presentation/pages/photo_gallery_page.dart';

// chương 3, bài 9
import '../tasks/03_Animation/task_09_motion_travel/data/datasources/motion_country_remote_data_source.dart';
import '../tasks/03_Animation/task_09_motion_travel/data/datasources/motion_photo_remote_data_source.dart';
import '../tasks/03_Animation/task_09_motion_travel/data/datasources/motion_travel_local_data_source.dart';
import '../tasks/03_Animation/task_09_motion_travel/data/datasources/motion_weather_remote_data_source.dart';
import '../tasks/03_Animation/task_09_motion_travel/data/repositories/motion_travel_repository.dart';
import '../tasks/03_Animation/task_09_motion_travel/presentation/pages/motion_travel_page.dart';


abstract final class AppRoutes {
  static const home = '/';
  static const task01 = '/task-01';
  static const task02 = '/task-02';
  static const task03 = '/task-03';

  static const task04 = '/task-04';
  static const task05 = '/task-05';
  static const task06 = '/task-06';
  static const task07 = '/task-07';
  static const task08 = '/task-08';
  static const task09 = '/task-09';
}


final Dio _chapter3Dio = Dio();


Future<void>? _chapter3Setup;
Future<void> _ensureChapter3Ready() => _chapter3Setup ??= _prepareChapter3();

Future<void> _prepareChapter3() async {
  if (!dotenv.isInitialized) {
    await dotenv.load(fileName: '.env');
  }
  await Hive.initFlutter();
}


class _Chapter3SetupGate extends StatefulWidget {
  const _Chapter3SetupGate({required this.child});

  final Widget child;

  @override
  State<_Chapter3SetupGate> createState() => _Chapter3SetupGateState();
}

class _Chapter3SetupGateState extends State<_Chapter3SetupGate> {
  late Future<void> _ready;

  @override
  void initState() {
    super.initState();
    _ready = _ensureChapter3Ready();
  }

  void _retry() {
    setState(() {
      _chapter3Setup = null;
      _ready = _ensureChapter3Ready();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Khởi tạo Chương 3')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 50),
                    const SizedBox(height: 12),
                    const Text(
                      'Không mở được dữ liệu của bài học',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return widget.child;
      },
    );
  }
}


final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),

   // chương 1
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

    // chương 2
    GoRoute(
      path: AppRoutes.task04,
      name: 'task04',
      builder: (context, state) => const CountryListPage(),
    ),
    GoRoute(
      path: AppRoutes.task05,
      name: 'task05',
      builder: (context, state) => const WeatherPage(),
    ),
    GoRoute(
      path: AppRoutes.task06,
      name: 'task06',
      builder: (context, state) => const VisualNewsEntryPage(),
    ),

    // chương 3
    GoRoute(
      path: AppRoutes.task07,
      name: 'task07',
      builder: (context, state) => MoodCardsPage(
        repository: ActivityRepository(
          remoteDataSource: ActivityRemoteDataSource(dio: _chapter3Dio),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.task08,
      name: 'task08',
      builder: (context, state) => _Chapter3SetupGate(
        child: PhotoGalleryPage(
          repository: PhotoRepository(
            remoteDataSource: PixabayRemoteDataSource(dio: _chapter3Dio),
          ),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.task09,
      name: 'task09',
      builder: (context, state) => _Chapter3SetupGate(
        child: MotionTravelPage(
          repository: MotionTravelRepository(
            countryRemote: MotionCountryRemoteDataSource(dio: _chapter3Dio),
            photoRemote: MotionPhotoRemoteDataSource(dio: _chapter3Dio),
            weatherRemote: MotionWeatherRemoteDataSource(dio: _chapter3Dio),
            local: MotionTravelLocalDataSource(),
          ),
        ),
      ),
    ),
  ],
);
