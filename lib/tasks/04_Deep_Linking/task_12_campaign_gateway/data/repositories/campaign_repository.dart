

import '../../domain/models/campaign_content.dart';
import '../datasources/campaign_local_data_source.dart';
import '../datasources/campaign_remote_data_source.dart';

class CampaignRepository {
  CampaignRepository({
    required this._remote,
    required this._local,
  });

  final CampaignRemoteDataSource _remote;
  final CampaignLocalDataSource _local;

  // cache còn mới trong 30p được dùng trực tiếp
  Future<CampaignContent> getCampaign(
    int id, {
    bool forceRefresh = false,
  }) async {
    // cache được ktra trước khi tạo request
    final cached = _local.getCampaign(id);

    final fresh = cached != null &&
        DateTime.now().difference(cached.cachedAt) <
            const Duration(minutes: 30);

    if (!forceRefresh && fresh) {
      return cached.copyWith(
        fromCache: true,
        stale: false,
      );
    }

    try {
      // Khởi chạy // 2 api
      final postFuture = _remote.getPost(id);

    

      final photoFuture = _remote
          .getPhoto(id)
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => null,
          );

      final post = await postFuture;
      final photo = await photoFuture;

      final result = CampaignContent.fromPost(
        post,
        cachedAt: DateTime.now(),
        imageUrl:
            photo?.url ?? cached?.imageUrl,
        photographer:
            photo?.photographer ??
                cached?.photographer,
        photographerUrl:
            photo?.photographerUrl ??
                cached?.photographerUrl,
      );

      await _local.saveCampaign(result);

      return result;
    } on CampaignNotFoundException {
      // 404 thì kh dùng cache cũ
      rethrow;
    } catch (_) {

      if (cached != null) {
        return cached.copyWith(
          fromCache: true,
          stale: true,
        );
      }

      rethrow;
    }
  }
}