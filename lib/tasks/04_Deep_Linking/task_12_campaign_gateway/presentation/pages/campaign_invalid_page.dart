

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../widgets/campaign_widgets.dart';

class CampaignInvalidPage
    extends StatelessWidget {
  const CampaignInvalidPage({
    super.key,
    required this.message,
    this.uri = '',
  });



  final String message;
  final String uri;

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          campaignBackground,

      appBar: AppBar(
        backgroundColor:
            campaignBackground,
        surfaceTintColor:
            Colors.transparent,
        title: const Text(
          'Liên kết không hợp lệ',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.all(18),
          children: [
            CampaignFailure(
              title:
                  'Không mở được chiến dịch',
              message: message,
              onBack: () {
                context.go(
                  '/campaigns',
                );
              },
            ),

            if (uri.isNotEmpty) ...[
              const SizedBox(height: 12),

              CampaignPanel(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Liên kết đã nhận',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    SelectableText(uri),

                    Align(
                      alignment:
                          Alignment.centerRight,
                      child:
                          TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: uri,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.copy,
                          size: 17,
                        ),
                        label: const Text(
                          'Sao chép',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            const Text(
              'Liên kết mẫu hợp lệ',
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            CampaignPanel(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.campaign,
                      color: campaignRed,
                    ),
                    title: const Text(
                      'Campaign #12',
                    ),
                    subtitle: const Text(
                      'myapp://campaign/12?source=qr',
                    ),
                    onTap: () {
                      context.go(
                        '/campaign/12?source=qr',
                      );
                    },
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(
                      Icons.campaign,
                      color: campaignRed,
                    ),
                    title: const Text(
                      'Campaign #45',
                    ),
                    subtitle: const Text(
                      'myapp://campaign/45?source=banner',
                    ),
                    onTap: () {
                      context.go(
                        '/campaign/45?source=banner',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}