

import '../domain/models/campaign_link.dart';
import 'package:hive_flutter/hive_flutter.dart';


import 'campaign_link_parser.dart';

class CampaignAuthService {
  CampaignAuthService({
    required Box<dynamic> box,
    required CampaignLinkParser parser,
  }) : _box = box, _parser = parser;

  final Box<dynamic> _box;
  final CampaignLinkParser _parser;

  static const _signedInKey =
      'signed_in';

  static const _pendingKey =
      'pending_campaign';

  // lấy trạng thái demo từ hive

  bool get isSignedIn {
    return _box.get(
          _signedInKey,
          defaultValue: false,
        ) ==
        true;
  }

  String? get pendingRawLink {
    final raw =
        _box.get(_pendingKey);

    if (raw is! Map) {
      return null;
    }

    return raw['uri']?.toString();
  }

  // đọc link đã lưu và parse lại sau khi app tắt,mở,bỏ qua nếu quá 30p
  CampaignLink? get pendingLink {
    final raw =
        _box.get(_pendingKey);

    if (raw is! Map) {
      return null;
    }

    try {
      final savedAt =
          DateTime.parse(
        raw['savedAt'].toString(),
      );

      // chỉ giữ 30 p
      if (DateTime.now().difference(savedAt) >
          const Duration(minutes: 30)) {
        return null;
      }

      final uri =
          raw['uri']?.toString();

      if (uri == null) {
        return null;
      }

      return _parser.parse(uri).link;
    } catch (_) {
      return null;
    }
  }

  bool get hasPending {
    return pendingLink != null;
  }



  Future<void> savePending(
    CampaignLink link,
  ) {
    return _box.put(
      _pendingKey,
      {
        'uri': link.appUri,
        'savedAt':
            DateTime.now()
                .toIso8601String(),
      },
    );
  }

  Future<void> clearPending() {
    return _box.delete(
      _pendingKey,
    );
  }

  Future<void> loginDemo() {
    return _box.put(
      _signedInKey,
      true,
    );
  }

  // kh xóa dữ liệu campaign cache

  Future<void> logout() {
    return _box.put(
      _signedInKey,
      false,
    );
  }
}