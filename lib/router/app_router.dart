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


// chương 4
import '../tasks/04_Deep_Linking/chapter4_dependencies.dart';

// bài 10
import '../tasks/04_Deep_Linking/task_10_post_link_router/presentation/pages/post_link_router_page.dart';
import '../tasks/04_Deep_Linking/task_10_post_link_router/presentation/pages/post_detail_page.dart';
import '../tasks/04_Deep_Linking/task_10_post_link_router/presentation/pages/post_invalid_link_page.dart';

// bài 11
import '../tasks/04_Deep_Linking/task_11_country_share_links/presentation/pages/country_share_list_page.dart';
import '../tasks/04_Deep_Linking/task_11_country_share_links/presentation/pages/country_share_detail_page.dart';

import '../tasks/04_Deep_Linking/task_11_country_share_links/presentation/pages/country_share_fallback_page.dart';

import '../tasks/04_Deep_Linking/task_11_country_share_links/services/country_share_link_parser.dart';

// bài 12
import '../tasks/04_Deep_Linking/task_12_campaign_gateway/presentation/pages/campaign_hub_page.dart';
import '../tasks/04_Deep_Linking/task_12_campaign_gateway/presentation/pages/campaign_detail_page.dart';

import '../tasks/04_Deep_Linking/task_12_campaign_gateway/presentation/pages/campaign_login_page.dart';

import '../tasks/04_Deep_Linking/task_12_campaign_gateway/presentation/pages/campaign_invalid_page.dart';


import '../tasks/04_Deep_Linking/task_12_campaign_gateway/presentation/pages/campaign_scanner_page.dart';
import '../tasks/04_Deep_Linking/task_12_campaign_gateway/services/campaign_coordinator.dart';



// chương 5
// bài 13
import '../tasks/05_Background_Tasks/task_13_daily_reminder/data/datasources/reminder_local_data_source.dart';
import '../tasks/05_Background_Tasks/task_13_daily_reminder/data/datasources/reminder_remote_data_source.dart';
import '../tasks/05_Background_Tasks/task_13_daily_reminder/data/repositories/reminder_repository.dart';
import '../tasks/05_Background_Tasks/task_13_daily_reminder/presentation/pages/daily_reminder_page.dart';

// bài 14
import '../tasks/05_Background_Tasks/task_14_weather_sync_worker/presentation/pages/weather_sync_page.dart';

// bài 15
import '../tasks/05_Background_Tasks/task_15_offline_news_sync/presentation/pages/news_sync_page.dart';

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

  static const task10 = '/task-10';
  static const task11 = '/task-11';
  static const task12 = '/task-12';

  // Chương 5
  static const task13 = '/task-13';
   static const task14 = '/task-14';
  static const task15 = '/task-15';
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

    

    // bài 10
    GoRoute(
      path: AppRoutes.task10,
      builder: (context, state) => PostLinkRouterPage(
        repository: Chapter4Dependencies.posts,
      ),
    ),
    GoRoute(
      path: '/post/:id',

      // ktra id trc khi gọi api
      redirect: (context, state) {

        final id = int.tryParse(
          state.pathParameters['id'] ?? '',
        );

        if (id != null && id > 0) return null;

        return Uri(
          path: '/invalid-link',
          queryParameters: {
            'uri': state.uri.toString(),

            'reason': 'ID bài viết phải là số nguyên dương.',
          },
        ).toString();
      },

      builder: (context, state) => PostDetailPage(
        repository: Chapter4Dependencies.posts,
        postId: int.parse(state.pathParameters['id']!),
        openedFromDeepLink:
            state.uri.queryParameters['source'] == 'deep-link',
      ),
    ),

    // trag xử lý liên kết sai
    GoRoute(
      path: '/invalid-link',
      builder: (context, state) => PostInvalidLinkPage(
        uri: state.uri.queryParameters['uri'] ?? '',
        message: state.uri.queryParameters['reason'] ??
            'Liên kết không hợp lệ.',
      ),
    ),





  // bài 11
    GoRoute(
      path: AppRoutes.task11,
      builder: (context, state) => CountryShareListPage(
        repository: Chapter4Dependencies.countries,
      ),
    ),

    GoRoute(
      path: '/countries',
      redirect: (context, state) {
        final raw = state.uri.queryParameters['region'];

        // k có region nghĩa là xem toàn bộ qg
        if (raw == null ||
            CountryShareLinkParser.normalizeRegion(raw) != null) {
          return null;
        }

        return Uri(
          path: '/country-link-fallback',
          queryParameters: {
            'uri': state.uri.toString(),
            'reason': 'Khu vực "$raw" không được hỗ trợ.',
          },
        ).toString();
      },
      builder: (context, state) => CountryShareListPage(
        repository: Chapter4Dependencies.countries,
        region: CountryShareLinkParser.normalizeRegion(
          state.uri.queryParameters['region'],
        ),
        openedFromDeepLink:
            state.uri.queryParameters['source'] == 'deep-link',
      ),
    ),

    // mở chi tiết theo mã qg
    GoRoute(
      path: '/country/:code',
      redirect: (context, state) {
        final code = state.pathParameters['code'] ?? '';

        if (CountryShareLinkParser.isValidCode(code)) {
          return null;
        }

        return Uri(
          path: '/country-link-fallback',
          queryParameters: {
            'uri': state.uri.toString(),
            'reason': 'Mã ISO phải có đúng 3 ký tự chữ cái.',
          },
        ).toString();
      },
      builder: (context, state) => CountryShareDetailPage(
        repository: Chapter4Dependencies.countries,
        code: state.pathParameters['code'],
        openedFromDeepLink:
            state.uri.queryParameters['source'] == 'deep-link',
      ),
    ),

    // dự phòng qg k có mã iso phù hơp
    GoRoute(
      path: '/country-name',
      redirect: (context, state) {
        final name =
            state.uri.queryParameters['name']?.trim() ?? '';

        if (name.isNotEmpty) return null;

        return Uri(
          path: '/country-link-fallback',
          queryParameters: {
            'uri': state.uri.toString(),
            'reason': 'Liên kết thiếu tên quốc gia.',
          },
        ).toString();
      },
      builder: (context, state) => CountryShareDetailPage(
        repository: Chapter4Dependencies.countries,
        name: state.uri.queryParameters['name'],
      ),
    ),

    // h.thị nguyên nhân khi lk sai
    GoRoute(
      path: '/country-link-fallback',
      builder: (context, state) => CountryShareFallbackPage(
        attemptedLink: state.uri.queryParameters['uri'] ?? '',
        message: state.uri.queryParameters['reason'] ??
            'Liên kết không hợp lệ.',
      ),
    ),





    // bài 12
    GoRoute(
      path: AppRoutes.task12,
      builder: (context, state) => const CampaignHubPage(),
    ),


    GoRoute(
      path: '/campaigns',
      builder: (context, state) => const CampaignHubPage(),
    ),


    GoRoute(
      path: '/campaign/:id',

      redirect: (context, state) async {
        // parser ktra id, source và chữ ký nếu có
        final result = CampaignCoordinator.instance.parser.parse(
          state.uri.toString(),
        );

        if (!result.isValid) {
          return Uri(
            path: '/campaign-invalid',
            queryParameters: {
              'uri': state.uri.toString(),
              'reason': result.message ??
                  'Liên kết chiến dịch không hợp lệ.',
            },
          ).toString();
        }

        // if ch login, thì lưu link chờ
        // vào hive rồi điều hướng đến trang login
        return CampaignCoordinator.instance.guard(result.link!);
      },

      builder: (context, state) {
        final result = CampaignCoordinator.instance.parser.parse(
          state.uri.toString(),
        );

        return result.isValid
            ? CampaignDetailPage(link: result.link!)
            : CampaignInvalidPage(
                uri: state.uri.toString(),
                message: result.message ??
                    'Liên kết không hợp lệ.',
              );
      },
    ),

    // trag login
    GoRoute(
      path: '/campaign-login',
      builder: (context, state) => const CampaignLoginPage(),
    ),

    // trang thông báo link lỗi
    GoRoute(
      path: '/campaign-invalid',
      builder: (context, state) => CampaignInvalidPage(
        uri: state.uri.queryParameters['uri'] ?? '',
        message: state.uri.queryParameters['reason'] ??
            'Liên kết không hợp lệ.',
      ),
    ),

    // trag qr
    GoRoute(
      path: '/campaign-scanner',
      builder: (context, state) => const CampaignScannerPage(),
    ),




   // bài 13
    GoRoute(
      path: AppRoutes.task13,
      name: 'task13',
      builder: (context, state) {
    
        final repository = ReminderRepository(
          local: ReminderLocalDataSource(),

          remote: ReminderRemoteDataSource(),
        );

        return DailyReminderPage(
          repository: repository,

          // cho ui biết người dùng vừa mở app từ t.báo
          openedFromNotification:
              state.uri.queryParameters['from'] == 'notification',
        );
      },
    ),

    //bài 14
    GoRoute(
      path: AppRoutes.task14,
      name: 'task14',
      builder: (context, state) {
        return const WeatherSyncPage();
      },
    ),

    // bài 15
    GoRoute(
      path: AppRoutes.task15,
      name: 'task15',
      builder: (context, state) {
        return const NewsSyncPage();
      },
    ),
  ],
);
