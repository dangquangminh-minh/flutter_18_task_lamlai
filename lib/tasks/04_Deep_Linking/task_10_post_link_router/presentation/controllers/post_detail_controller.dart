

import 'package:flutter/material.dart';

import '../../data/datasources/post_remote_data_source.dart';
import '../../data/repositories/post_repository.dart';
import '../../domain/models/post_model.dart';

enum PostDetailStatus {
  loading,
  success,
  notFound,
  error,
}

class PostDetailController extends ChangeNotifier {
  PostDetailController({
    required PostRepository repository,
    required this.postId,
  }) : _repository = repository;

  final PostRepository _repository;
  final int postId;

  PostDetailStatus status = PostDetailStatus.loading;

  // post null khi đang loading,lỗi, trang k tr.cập nếu chưa success

  PostModel? post;
  String? errorMessage;

  // phát load trước khi await
  Future<void> load() async {
    status = PostDetailStatus.loading;
    errorMessage = null;

    notifyListeners();

    try {
      post = await _repository.getPost(postId);
      status = PostDetailStatus.success;
    } on PostNotFoundException {
      status = PostDetailStatus.notFound;
      errorMessage =
          'Không tìm thấy bài viết #$postId.';
    } on PostRequestException catch (e) {
      status = PostDetailStatus.error;
      errorMessage = e.message;
    } catch (_) {
      status = PostDetailStatus.error;
      errorMessage =
          'Đã xảy ra lỗi khi tải bài viết.';
    }

    notifyListeners();
  }
}