import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'router/app_router.dart';


import 'tasks/04_Deep_Linking/chapter4_dependencies.dart';
import 'tasks/04_Deep_Linking/task_10_post_link_router/services/deep_link_bootstrap.dart';


import 'tasks/05_Background_Tasks/chapter5_bootstrap.dart';
import 'tasks/05_Background_Tasks/task_13_daily_reminder/services/reminder_notification_service.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // đọc api từ .env
  await dotenv.load(fileName: '.env');


  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );

  await Chapter4Dependencies.initialize();

  final notificationLaunchPayload = await Chapter5Bootstrap.initialize(
    onReminderTap: (payload) {
      if (payload == ReminderNotificationService.payload) {
        appRouter.go('${AppRoutes.task13}?from=notification');
      }
    },
  );

  final appLinks = Chapter4Dependencies.appLinks;

  runApp(MyApp(appLinks: appLinks));


    if (notificationLaunchPayload == ReminderNotificationService.payload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appRouter.go('${AppRoutes.task13}?from=notification');
      });
    }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.appLinks,
  });


  final AppLinks appLinks;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter 18 Tasks',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF245D85),
        ),
        useMaterial3: true,
      ),


      routerConfig: appRouter,

      
      builder: (context, child) {
        return DeepLinkBootstrap(
          appLinks: appLinks,
          router: appRouter,


          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}