

import 'dart:convert';

import 'package:crypto/crypto.dart';
import '../domain/models/campaign_link.dart';



enum CampaignLinkError {
  malformed,
  expired,
  invalidSignature,
}

class CampaignLinkParseResult {
  const CampaignLinkParseResult.success(
    this.link,
  )   : error = null,
        message = null;

  const CampaignLinkParseResult.failure(
    this.error,
    this.message,
  ) : link = null;

  final CampaignLink? link;
  final CampaignLinkError? error;
  final String? message;

  bool get isValid => link != null;
}

class CampaignLinkParser {
  CampaignLinkParser({
    required this.demoSecret,
  });

  final String demoSecret;

  CampaignLinkParseResult parse(
    String raw,
  ) {
    final uri = Uri.tryParse(
      raw.trim(),
    );

    if (uri == null) {
      return const CampaignLinkParseResult.failure(
        CampaignLinkError.malformed,
        'Đường dẫn không phải URI hợp lệ.',
      );
    }

    return parseUri(uri);
  }

  // validation gồm id dương, source h.lệ, kh có query lạ hoặc tham số lặp
  CampaignLinkParseResult parseUri(
    Uri uri,
  ) {
    String? rawId;

    // myapp://campaign/12
    if (uri.scheme.toLowerCase() == 'myapp' &&
        uri.host.toLowerCase() == 'campaign' &&
        uri.pathSegments.length == 1) {
      rawId = uri.pathSegments.first;
    }

    // /campaign/12
    else if (uri.scheme.isEmpty &&
        uri.host.isEmpty &&
        uri.pathSegments.length == 2 &&
        uri.pathSegments.first == 'campaign') {
      rawId = uri.pathSegments[1];
    }

    if (rawId == null ||  !RegExp(r'^[0-9]+$').hasMatch(rawId)) {
      return const CampaignLinkParseResult.failure(
        CampaignLinkError.malformed,
        'Định dạng đúng: '
        'myapp://campaign/{id}?source=qr',
      );
    }

    final id = int.tryParse(rawId);

    if (id == null || id <= 0) {
      return const CampaignLinkParseResult.failure(
        CampaignLinkError.malformed,
        'ID chiến dịch phải là số nguyên dương.',
      );
    }



    const allowedKeys = {
      'source',
      'exp',
      'sig',
    };

    for (final key
        in uri.queryParametersAll.keys) {
      if (!allowedKeys.contains(key)) {
        return CampaignLinkParseResult.failure(
          CampaignLinkError.malformed,
          'Tham số "$key" không được hỗ trợ.',
        );
      }

      if (uri.queryParametersAll[key]!.length != 1) {
        return CampaignLinkParseResult.failure(
          CampaignLinkError.malformed,
          'Tham số "$key" bị lặp.',
        );
      }
    }

    final source =
        (uri.queryParameters['source'] ??
                'direct')
            .trim()
            .toLowerCase();

    if (!RegExp(
      r'^[a-z][a-z0-9_-]{0,31}$',
    ).hasMatch(source)) {
      return const CampaignLinkParseResult.failure(
        CampaignLinkError.malformed,
        'source không hợp lệ.',
      );
    }

    final expRaw =
        uri.queryParameters['exp'];

    final sig =
        uri.queryParameters['sig'];


    if (expRaw == null && sig == null) {
      return CampaignLinkParseResult.success(
        CampaignLink(
          id: id,
          source: source,
        ),
      );
    }


    if (expRaw == null || sig == null) {
      return const CampaignLinkParseResult.failure(
        CampaignLinkError.malformed,
        'Signed Link cần cả exp và sig.',
      );
    }

    final exp = int.tryParse(expRaw);

    if (exp == null ||
        exp <= 0 ||
        !RegExp(r'^[a-f0-9]{64}$')
            .hasMatch(sig)) {
      return const CampaignLinkParseResult.failure(
        CampaignLinkError.malformed,
        'Signature hoặc expiry sai định dạng.',
      );
    }

    if (demoSecret.length < 16) {
      return const CampaignLinkParseResult.failure(
        CampaignLinkError.invalidSignature,
        'CAMPAIGN_DEMO_HMAC_KEY chưa hợp lệ.',
      );
    }


    final expected = _sign(
      id,
      source,
      exp,
    );

    if (!_constantTimeEquals(
      expected,
      sig,
    )) {
      return const CampaignLinkParseResult.failure(
        CampaignLinkError.invalidSignature,
        'Chữ ký Deep Link không hợp lệ.',
      );
    }

    final now =
        DateTime.now().millisecondsSinceEpoch ~/
            1000;

    // link đã hết hạn kh được đi tiếp vào màn hình c.tiết

    if (now > exp) {
      return const CampaignLinkParseResult.failure(
        CampaignLinkError.expired,
        'Liên kết chiến dịch đã hết hạn.',
      );
    }

    return CampaignLinkParseResult.success(
      CampaignLink(
        id: id,
        source: source,
        exp: exp,
        sig: sig,
      ),
    );
  }



  CampaignLink? createSignedLink(
    int id,
    String source, {
    Duration validFor =
        const Duration(minutes: 5),
  }) {
    if (demoSecret.length < 16) {
      return null;
    }

    final normalized =
        source.trim().toLowerCase();

    final exp = DateTime.now()
            .add(validFor)
            .millisecondsSinceEpoch ~/
        1000;

    final sig = _sign(
      id,
      normalized,
      exp,
    );

    return CampaignLink(
      id: id,
      source: normalized,
      exp: exp,
      sig: sig,
    );
  }

  String _sign(
    int id,
    String source,
    int exp,
  ) {
    final payload =
        '$id|$source|$exp';

    return Hmac(
      sha256,
      utf8.encode(demoSecret),
    )
        .convert(
          utf8.encode(payload),
        )
        .toString();
  }

  // so sánh chữ ký theo cùng số vòng lặp
  bool _constantTimeEquals(
    String a,
    String b,
  ) {
    if (a.length != b.length) {
      return false;
    }

    var difference = 0;

    for (var i = 0; i < a.length; i++) {
      difference |=
          a.codeUnitAt(i) ^
          b.codeUnitAt(i);
    }

    return difference == 0;
  }
}