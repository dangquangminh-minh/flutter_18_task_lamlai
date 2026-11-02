

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'post_deep_link_parser.dart';

import '../../task_11_country_share_links/services/country_share_link_parser.dart';

import '../../task_12_campaign_gateway/services/campaign_coordinator.dart';

class DeepLinkBootstrap extends StatefulWidget {
  const DeepLinkBootstrap({
    super.key,
    required this.appLinks,
    required this.router,
    required this.child,
  });

  final AppLinks appLinks;
  final GoRouter router;
  final Widget child;

  @override
  State<DeepLinkBootstrap> createState() {
    return _DeepLinkBootstrapState();
  }
}

class _DeepLinkBootstrapState
    extends State<DeepLinkBootstrap> {
  StreamSubscription<Uri>? subscription;

  String? lastUri;
  DateTime? lastHandledAt;

  @override
  void initState() {
    super.initState();

    debugPrint(
      'DEEPLINK BOOTSTRAP STARTED',
    );

    _start();
  }

  Future<void> _start() async {

    // nhận link khi app đang chạy
    subscription =
        widget.appLinks.uriLinkStream.listen(
      (uri) async {
        debugPrint(
          'DEEPLINK STREAM EVENT: $uri',
        );

        await _handle(uri);
      },
      onError: (Object error) {
        debugPrint(
          'DEEPLINK STREAM ERROR: $error',
        );
      },
    );

 
    try {
      // getInitialLink x.lý tình huống app chưa chạy
      final initial =
          await widget.appLinks.getInitialLink();

      debugPrint(
        'DEEPLINK INITIAL: $initial',
      );

      if (initial != null) {

        WidgetsBinding.instance
            .addPostFrameCallback(
          (_) async {
            await _handle(initial);
          },
        );

        return;
      }

      final coordinator =
          CampaignCoordinator.instance;

      if (!coordinator.auth.isSignedIn &&
          coordinator.auth.hasPending) {
        WidgetsBinding.instance
            .addPostFrameCallback(
          (_) {
            widget.router.go(
              '/campaign-login',
            );
          },
        );
      }
    } catch (e) {
      debugPrint(
        'DEEPLINK INITIAL ERROR: $e',
      );
    }
  }

  Future<void> _handle(
    Uri uri,
  ) async {
    final raw = uri.toString();
    final now = DateTime.now();

    debugPrint(
      'DEEPLINK HANDLE: $raw',
    );

    // tránh x.lý cùng 1 link 2 lần
    if (raw == lastUri &&
        lastHandledAt != null &&
        now.difference(lastHandledAt!) <
            const Duration(seconds: 1)) {
      debugPrint(
        'DEEPLINK DUPLICATE SKIPPED',
      );

      return;
    }

    lastUri = raw;
    lastHandledAt = now;

    if (uri.scheme.toLowerCase() !=
        'myapp') {
      debugPrint(
        'DEEPLINK WRONG SCHEME',
      );

      return;
    }

    final host =
        uri.host.toLowerCase();

    debugPrint(
      'DEEPLINK HOST: $host',
    );


    // bài 12
    if (host == 'campaign') {
      final destination =
          await CampaignCoordinator
              .instance
              .dispatchRaw(raw);

      debugPrint(
        'TASK12 DESTINATION: $destination',
      );


      // foreground điều hướng trực tiếp
      widget.router.go(
        destination,
      );

      return;
    }


    // bài 10 
    // post chỉ cần id nên chuyển thẳng route c.tiết khi parser ok
    if (host == 'post') {
      final id =
          PostDeepLinkParser.parseUri(
        uri,
      );

      if (id != null) {
        final destination =
            '/post/$id?source=deep-link';

        debugPrint(
          'TASK10 DESTINATION: $destination',
        );

        widget.router.go(
          destination,
        );
      } else {
        final destination = Uri(
          path: '/invalid-link',
          queryParameters: {
            'uri': raw,
            'reason':
                'Deep Link bài viết '
                'không hợp lệ.',
          },
        ).toString();

        widget.router.go(
          destination,
        );
      }

      return;
    }


    // bài 11
    if (host == 'countries' ||
        host == 'country' || host == 'country-name') {
      final result =
          CountryShareLinkParser
              .parseUri(uri);

      switch (result.kind) {
        case CountryShareLinkKind.countries:
          final destination = Uri(
            path: '/countries',
            queryParameters: {
              if (result.region != null)
                'region': result.region!,
              'source': 'deep-link',

            },
          ).toString();

          debugPrint(
            'TASK11 LIST: $destination',
          );

          widget.router.go(
            destination,
          );

          return;

        case CountryShareLinkKind.country:
          final destination =
              result.name != null
                  ? Uri(path: '/country-name', queryParameters: {'name': result.name!, 'source':'deep-link'}).toString()
                  : '/country/${result.code}?source=deep-link';

          debugPrint(
            'TASK11 DETAIL: $destination',
          );

          widget.router.go(
            destination,
          );

          return;

        case CountryShareLinkKind.invalid:
          final destination = Uri(
            path:
                '/country-link-fallback',
            queryParameters: {
              'uri': raw,
              'reason':
                  result.message ??
                      'Country Deep Link '
                          'không hợp lệ.',
            },
          ).toString();

          widget.router.go(
            destination,
          );

          return;
      }
    }


    // link k hỗ trợ
    final destination = Uri(
      path: '/invalid-link',
      queryParameters: {
        'uri': raw,
        'reason':
            'Deep Link không được hỗ trợ.',
      },
    ).toString();

    widget.router.go(
      destination,
    );
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return widget.child;
  }
}