// MobileScanner đọc QR rồi chuyển URI cho cùng coordinator với link nhập thủ công.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../services/campaign_coordinator.dart';


class CampaignScannerPage
    extends StatefulWidget {
  const CampaignScannerPage({
    super.key,
  });

  @override
  State<CampaignScannerPage> createState() =>
      _CampaignScannerPageState();
}

class _CampaignScannerPageState
    extends State<CampaignScannerPage> {
  final scanner =
      MobileScannerController(
    formats: [
      BarcodeFormat.qrCode,
    ],
  );



  bool handled = false;

  Future<void> _onDetect(
    BarcodeCapture capture,
  ) async {
    if (handled ||
        capture.barcodes.isEmpty) {
      return;
    }

    final raw =
        capture.barcodes.first.rawValue;

    if (raw == null ||
        raw.trim().isEmpty) {
      return;
    }

    handled = true;


    await scanner.stop();

    final route =
        await CampaignCoordinator.instance
            .dispatchRaw(raw);

    if (!mounted) return;

    context.go(route);
  }

  @override
  void dispose() {
    scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black,

      appBar: AppBar(
        backgroundColor:
            Colors.black,
        foregroundColor:
            Colors.white,
        title: const Text(
          'Quét QR chiến dịch',
        ),
      ),

      body: Stack(
        children: [
          MobileScanner(
            controller: scanner,
            onDetect: _onDetect,
          ),

          Center(
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration:
                    BoxDecoration(
                  border:
                      Border.all(
                    color:
                        const Color(0xFFCBF268),
                    width: 3,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(18),
                ),
              ),
            ),
          ),

          const Align(
            alignment:
                Alignment.bottomCenter,
            child: Padding(
              padding:
                  EdgeInsets.all(24),
              child: Text(
                'Quét QR chứa '
                'myapp://campaign/{id}?source=qr',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}