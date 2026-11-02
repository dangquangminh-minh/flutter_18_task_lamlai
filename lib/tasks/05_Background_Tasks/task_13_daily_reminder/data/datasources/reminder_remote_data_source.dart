
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/todo_suggestion.dart';


class ReminderApiException implements Exception {
  const ReminderApiException(this.message);

  final String message;

  @override
  String toString() => message;
}


class ReminderRemoteDataSource {
  //đặt timeout để tránh load vô hạn khi mất kn
  Future<TodoSuggestion> getSuggestion() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://jsonplaceholder.typicode.com/todos/1',),
          )
          .timeout(
            const Duration(seconds: 8),
          );

      if (response.statusCode != 200) {
        throw ReminderApiException(
          
          'Máy chủ trả về lỗi '
          '${response.statusCode}.',
        );
      }

      final decoded =
          jsonDecode(response.body);

      if (decoded is! Map) {
        throw const ReminderApiException(
          'Dữ liệu API không hợp lệ.',
        );
      }

      return TodoSuggestion.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } on ReminderApiException {
      rethrow;
    } catch (_) {
      throw const ReminderApiException(
        'Không tải được gợi ý học tập. '
        'Hãy kiểm tra mạng và thử lại.',
      );
    }
  }
}