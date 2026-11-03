

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CampaignAnalyticsService {
  CampaignAnalyticsService({
    required this._box,
  });

  final Box<dynamic> _box;

  bool get firebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // log vẫn hđ khi firebase chưa được lk
  Future<void> track(
    String event, {
    int? campaignId,
    String? source,
    String? reason,
  }) async {
    final parameters =
        <String, Object>{
      'campaign_id': ?campaignId,
      'link_source': ?source,
      'reason': ?reason,
    };

    debugPrint(
      'TASK12 ANALYTICS: '
      '$event $parameters',
    );


    try {
      // chỉ giữ tối đa 100 event local
      final events =
          (_box.get('events') as List?)
                  ?.toList() ??
              <dynamic>[];

      events.add({
        'event': event,
        ...parameters,
        'at':
            DateTime.now()
                .toIso8601String(),
      });


      if (events.length > 100) {
        events.removeRange(
          0,
          events.length - 100,
        );
      }

      await _box.put(
        'events',
        events,
      );
    } catch (_) {}


    //chưa thiết lập firebase thì app vẫn hđ
    if (firebaseReady) {
      try {
        await FirebaseAnalytics.instance
            .logEvent(
          name: event,
          parameters: parameters,
        );
      } catch (e) {
        debugPrint(
          'TASK12 FIREBASE ERROR: $e',
        );
      }
    }
  }
}