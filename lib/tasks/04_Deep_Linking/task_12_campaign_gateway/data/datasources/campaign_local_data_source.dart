

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/campaign_content.dart';

class CampaignLocalDataSource {
  CampaignLocalDataSource({
    required this._box,
  });

  final Box<dynamic> _box;

  String _key(int id) {
    return 'campaign_$id';
  }

  // đọc bản cache theo id, nếu thiếu thì trả null để repo gọi api

  CampaignContent? getCampaign(
    int id,
  ) {
    final raw = _box.get(
      _key(id),
    );

    if (raw is! Map) {
      return null;
    }

    try {
      return CampaignContent.fromMap(
        raw,
      );
    } catch (_) {
      return null;
    }
  }



  Future<void> saveCampaign(
    CampaignContent campaign,
  ) {
    return _box.put(
      _key(campaign.id),
      campaign.toMap(),
    );
  }

  Future<void> removeCampaign(
    int id,
  ) {
    return _box.delete(
      _key(id),
    );
  }

  Future<void> clear() {
    return _box.clear();
  }
}