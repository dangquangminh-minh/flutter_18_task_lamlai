

import '../../domain/models/activity_model.dart';
import '../datasources/activity_remote_data_source.dart';

class ActivityRepository {
  ActivityRepository({
    required this._remoteDataSource,
  });

  final ActivityRemoteDataSource _remoteDataSource;

  Future<ActivityModel> getRandomActivity() {
    return _remoteDataSource.getRandomActivity();
  }

  //tải m.định 5 hđ
  Future<List<ActivityModel>> getRandomActivities({
    int count = 5,
  }) async {
    final result = await Future.wait(
      List.generate(
        count,
        (_) => _remoteDataSource.getRandomActivity(),
      ),
    );

    final unique = <String, ActivityModel>{};

    for (final item in result) {
      
      unique[item.id] = item; //nếu id t.tại thì dl mới sẽ thay dl cũ
    }

    return unique.values.toList();
  }
}