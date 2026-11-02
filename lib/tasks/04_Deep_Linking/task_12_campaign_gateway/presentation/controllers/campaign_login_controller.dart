

import 'package:flutter/material.dart';

import '../../services/campaign_coordinator.dart';

class CampaignLoginController
    extends ChangeNotifier {
  CampaignLoginController({
    required CampaignCoordinator coordinator,
  }) : _coordinator = coordinator;

  final CampaignCoordinator _coordinator;

  bool loading = false;
  String? errorMessage;

  String? get pendingLink {
    return _coordinator.auth.pendingRawLink;
  }

  // ktra đầu vào  để minh họa login

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty) {
      errorMessage =
          'Vui lòng nhập tài khoản.';
      notifyListeners();
      return null;
    }

    if (password.trim().length < 4) {
      errorMessage =
          'Mật khẩu demo cần ít nhất 4 ký tự.';
      notifyListeners();
      return null;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await _coordinator
          .completeDemoLogin();
    } catch (_) {
      errorMessage =
          'Không thể hoàn tất Auth Redirect.';
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}