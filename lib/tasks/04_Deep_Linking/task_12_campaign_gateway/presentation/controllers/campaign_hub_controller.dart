

import 'package:flutter/material.dart';

import '../../services/campaign_coordinator.dart';

class CampaignHubController extends ChangeNotifier {
  CampaignHubController({
    required CampaignCoordinator coordinator,
  }) : _coordinator = coordinator {
    rawLink =
        'myapp://campaign/12?source=qr';
  }

  final CampaignCoordinator _coordinator;

  late String rawLink;

  int selectedId = 12;
  String selectedSource = 'qr';

  bool get signedIn =>
      _coordinator.auth.isSignedIn;

  void updateRawLink(
    String value,
  ) {
    rawLink = value;
  }

  // chọn card mẫu sẽ dựng uri mới từ id và source

  void selectCampaign({
    required int id,
    required String source,
  }) {
    selectedId = id;
    selectedSource = source;

    rawLink = Uri(
      scheme: 'myapp',
      host: 'campaign',
      path: '/$id',
      queryParameters: {
        'source': source,
      },
    ).toString();

    notifyListeners();
  }



  String? createSignedLink() {
    final parsed =
        _coordinator.parser.parse(
      rawLink,
    );

    if (!parsed.isValid) {
      return null;
    }

    final currentLink =
        parsed.link!;

    final signedLink =
        _coordinator.parser
            .createSignedLink(
      currentLink.id,
      currentLink.source,
    );

    if (signedLink == null) {
      return null;
    }

    rawLink =
        signedLink.appUri;

    notifyListeners();

    return rawLink;
  }

  Future<String> dispatch() {
    return _coordinator.dispatchRaw(
      rawLink,
    );
  }

  Future<void> logout() async {
    await _coordinator.logoutDemo();

    notifyListeners();
  }
}