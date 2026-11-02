

import '../../domain/models/reminder_settings.dart';
import '../../domain/models/todo_suggestion.dart';
import '../datasources/reminder_local_data_source.dart';
import '../datasources/reminder_remote_data_source.dart';


class ReminderRepository {
  ReminderRepository({
    required ReminderLocalDataSource local,
    required ReminderRemoteDataSource remote,
  }) : _local = local,
       _remote = remote;

  final ReminderLocalDataSource _local;
  final ReminderRemoteDataSource _remote;

  // lấy lịch nhắc đã lưu trog t.bị
  Future<ReminderSettings> loadSettings() {
    return _local.loadSettings();
  }

  // chuyển y.cầu lưu c.hình xuống local data source
  Future<void> saveSettings(ReminderSettings settings,) 
  {
    return _local.saveSettings(settings);
  }


  Future<TodoSuggestion> getSuggestion() {

    return _remote.getSuggestion();
  }
}