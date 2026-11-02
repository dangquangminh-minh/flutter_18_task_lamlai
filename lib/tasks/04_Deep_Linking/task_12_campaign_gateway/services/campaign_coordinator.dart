

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/datasources/campaign_local_data_source.dart';
import '../data/datasources/campaign_remote_data_source.dart';
import '../data/repositories/campaign_repository.dart';
import '../domain/models/campaign_link.dart';
import 'package:hive_flutter/hive_flutter.dart';


import 'campaign_analytics_service.dart';
import 'campaign_auth_service.dart';
import 'campaign_link_parser.dart';

class CampaignCoordinator {
  CampaignCoordinator._({
    required this.parser,
    required this.auth,
    required this.analytics,
    required this.repository,
  });

  static CampaignCoordinator?
      _instance;

  static CampaignCoordinator get instance {
    final value = _instance;

    if (value == null) {
      throw StateError(
        'CampaignCoordinator chưa initialize.',
      );
    }

    return value;
  }

  final CampaignLinkParser parser;
  final CampaignAuthService auth;
  final CampaignAnalyticsService analytics;
  final CampaignRepository repository;



  static Future<void> initialize({
    required Dio dio,
  }) async {
    final cacheBox =
        await Hive.openBox<dynamic>(
      'task12_campaign_cache',
    );

    final stateBox =
        await Hive.openBox<dynamic>(
      'task12_campaign_state',
    );

    final analyticsBox =
        await Hive.openBox<dynamic>(
      'task12_campaign_analytics',
    );

    final parser =
        CampaignLinkParser(
      demoSecret:
          dotenv.env[
                  'CAMPAIGN_DEMO_HMAC_KEY']
              ?.trim() ??
          '',
    );

    final auth =
        CampaignAuthService(
      box: stateBox,
      parser: parser,
    );

    final analytics =
        CampaignAnalyticsService(
      box: analyticsBox,
    );

    final repository =
        CampaignRepository(
      remote:
          CampaignRemoteDataSource(
        dio: dio,
      ),
      local:
          CampaignLocalDataSource(
        box: cacheBox,
      ),
    );

    _instance = CampaignCoordinator._(
      parser: parser,
      auth: auth,
      analytics: analytics,
      repository: repository,
    );
  }

  String _invalidRoute({
    required String uri,
    required String reason,
  }) {
    return Uri(
      path: '/campaign-invalid',
      queryParameters: {
        'uri': uri,
        'reason': reason,
      },
    ).toString();
  }


  Future<String> dispatchRaw(
    String raw,
  ) async {
    final result =
        parser.parse(raw);



    if (!result.isValid) {
      await analytics.track(
        'campaign_invalid_link',
        reason:
            result.error?.name,
      );

      return _invalidRoute(
        uri: raw,
        reason:
            result.message ??
            'Liên kết không hợp lệ.',
      );
    }

    final link =
        result.link!;

    await analytics.track(
      'campaign_link_open',
      campaignId: link.id,
      source: link.source,
    );

    return link.route;
  }

  // chưa login: ghi uri vào hive rồi trả route login
  Future<String?> guard(
    CampaignLink link,
  ) async {
    // khi đã login, guard trả null để gorouter mở c.tiết
    if (auth.isSignedIn) {
      return null;
    }

    await auth.savePending(link);

    await analytics.track(
      'campaign_auth_redirect',
      campaignId: link.id,
      source: link.source,
    );

    return '/campaign-login';
  }

  //ktra lại hạn sử dụng rồi trở về campaign
  Future<String> completeDemoLogin() async {
    final pending =
        auth.pendingLink;

    if (pending == null) {

      final raw = auth.pendingRawLink;
      await auth.clearPending();
      if (raw == null) {
        await auth.loginDemo();
        return '/campaigns';
      }

      return _invalidRoute(
        uri: raw,
        reason: 'Deep Link đang chờ đã hết hạn hoặc không còn hợp lệ.',
      );
    }

    await auth.loginDemo();

    await auth.clearPending();

    await analytics.track(
      'campaign_login_success',
      campaignId: pending.id,
      source: pending.source,
    );

    return pending.route;
  }

  Future<void> logoutDemo() async {
    await auth.logout();

    await analytics.track(
      'campaign_logout',
    );
  }
}