

import 'dart:ui';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'task_14_weather_sync_worker/services/weather_worker_service.dart';
import 'task_15_offline_news_sync/services/news_worker_service.dart';

@pragma('vm:entry-point')

void appBackgroundTaskDispatcher() {

  Workmanager().executeTask(
    (
      taskName,
      inputData,
    ) async {

      DartPluginRegistrant.ensureInitialized();

      final data =  Map<String, dynamic>.from(inputData ?? <String, dynamic>{},
      );


      //bài 14
      if (taskName == weatherPeriodicTaskName || taskName ==  weatherOneOffTaskName) {
        await Hive.initFlutter();

        return WeatherWorkerExecutor.execute(
          taskName: taskName,
          inputData: data,
        );
      }

      //bài 15
      if (taskName ==  newsPeriodicTaskName || taskName ==  newsOneOffTaskName) {
        return NewsWorkerExecutor.execute(
          taskName: taskName,
          inputData: data,
        );
      }

      return true;
    },
  );
}


class BackgroundTaskBootstrap {
  BackgroundTaskBootstrap._();


  static Future<void> initialize() {
    return Workmanager().initialize(
      appBackgroundTaskDispatcher,
    );
  }
}