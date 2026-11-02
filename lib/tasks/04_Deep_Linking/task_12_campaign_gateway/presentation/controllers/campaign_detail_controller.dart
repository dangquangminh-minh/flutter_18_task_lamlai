

import 'package:flutter/material.dart';

import '../../data/datasources/campaign_remote_data_source.dart';
import '../../data/repositories/campaign_repository.dart';
import '../../domain/models/campaign_content.dart';
import '../../domain/models/campaign_link.dart';
import '../../services/campaign_analytics_service.dart';

enum CampaignDetailStatus {
  loading,
  success,
  notFound,
  error,
}

class CampaignDetailController
    extends ChangeNotifier {
  CampaignDetailController({
    required CampaignRepository repository,
    required CampaignAnalyticsService analytics,
    required this.link,
  }) : _repository = repository, _analytics = analytics;

  final CampaignRepository _repository;
  final CampaignAnalyticsService _analytics;

  final CampaignLink link;

  CampaignDetailStatus status =
      CampaignDetailStatus.loading;

  CampaignContent? campaign;
  String? errorMessage;



  Future<void> load({
    bool forceRefresh = false,
  }) async {
    status =
        CampaignDetailStatus.loading;

    errorMessage = null;

    notifyListeners();

    try {
      campaign =
          await _repository.getCampaign(
        link.id,
        forceRefresh: forceRefresh,
      );

      status =
          CampaignDetailStatus.success;

  

      await _analytics.track(
        'campaign_view',
        campaignId: link.id,
        source: link.source,
        reason: campaign!.fromCache
            ? campaign!.stale
                ? 'stale_cache'
                : 'cache'
            : 'network',
      );
    } on CampaignNotFoundException {
      status =
          CampaignDetailStatus.notFound;

      errorMessage =
          'Không tìm thấy chiến dịch #${link.id}.';

      await _analytics.track(
        'campaign_not_found',
        campaignId: link.id,
        source: link.source,
      );
    } on CampaignRequestException catch (e) {
      status =
          CampaignDetailStatus.error;

      errorMessage = e.message;

      await _analytics.track(
        'campaign_load_error',
        campaignId: link.id,
        source: link.source,
      );
    } catch (_) {
      status =
          CampaignDetailStatus.error;

      errorMessage =
          'Đã xảy ra lỗi khi tải chiến dịch.';
    }

    notifyListeners();
  }
}