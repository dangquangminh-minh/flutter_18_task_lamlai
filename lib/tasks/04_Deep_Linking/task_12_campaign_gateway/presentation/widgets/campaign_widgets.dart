

import 'package:flutter/material.dart';

const campaignRed =
    Color(0xFF151E23);

const campaignBackground =
    Color(0xFFF2F5EF);



class CampaignPanel
    extends StatelessWidget {
  const CampaignPanel({
    super.key,
    required this.child,
    this.padding =
        const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(23),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}



class CampaignFailure
    extends StatelessWidget {
  const CampaignFailure({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.onBack,
  });

  final String title;
  final String message;

  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor:
                  Color(0xFFE8F4CE),
              child: Icon(
                Icons.link_off_rounded,
                color: campaignRed,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),

            if (onRetry != null) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  style:
                      FilledButton.styleFrom(
                    backgroundColor:
                        campaignRed,
                  ),
                  onPressed: onRetry,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  label: const Text(
                    'Thử lại',
                  ),
                ),
              ),
              const SizedBox(height: 9),
            ],

            if (onBack != null)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.home_outlined,
                  ),
                  label: const Text(
                    'Về danh sách chiến dịch',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}