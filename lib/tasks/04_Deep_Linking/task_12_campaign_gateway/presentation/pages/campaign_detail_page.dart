

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/models/campaign_content.dart';
import '../../domain/models/campaign_link.dart';

import '../../services/campaign_coordinator.dart';
import '../controllers/campaign_detail_controller.dart';


class CampaignDetailPage extends StatefulWidget {
  const CampaignDetailPage({super.key, required this.link});
  final CampaignLink link;
  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  static const dark = Color(0xFF151E23);
  static const lime = Color(0xFFCBF268);
  late CampaignDetailController controller;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    controller = CampaignDetailController(
      repository: CampaignCoordinator.instance.repository,
      analytics: CampaignCoordinator.instance.analytics,
      link: widget.link,
    )..load();
  }

  @override

  void didUpdateWidget(covariant CampaignDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.link.appUri != widget.link.appUri) {
      controller.dispose();
      _createController();
    }
  }

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  Future<void> _share() async {
    await SharePlus.instance.share(ShareParams(text: widget.link.appUri));
    await CampaignCoordinator.instance.analytics.track('campaign_share',
      campaignId: widget.link.id, source: widget.link.source);
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.link.appUri));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép Deep Link')));
  }

  Widget _failed(String title, String description) => Center(child: Padding(padding: const EdgeInsets.all(25),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_off_rounded, color: dark, size: 55),
      const SizedBox(height: 14), Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      const SizedBox(height: 9), Text(description, textAlign: TextAlign.center),
      const SizedBox(height: 17), FilledButton.icon(
        onPressed: () => controller.load(forceRefresh: true), icon: const Icon(Icons.refresh_rounded),
        label: const Text('Thử lại'), style: FilledButton.styleFrom(backgroundColor: dark)),
    ])));



  Widget _picture(CampaignContent content) {
    final url = content.imageUrl;
    if (url == null || url.isEmpty) return _imageFallback();
    return CachedNetworkImage(imageUrl: url, fit: BoxFit.cover,
      placeholder: (_, _) => const Center(child: CircularProgressIndicator(color: dark)),
      errorWidget: (_, _, _) => _imageFallback());
  }

  Widget _imageFallback() => Container(color: const Color(0xFFD8E2C7), child: const Center(
    child: Icon(Icons.image_not_supported_outlined, size: 56, color: dark)));

  // h.thị nhãn cache/stale để số liệu kh bị hiểu là dl mới

  Widget _content(CampaignContent c) => ListView(padding: const EdgeInsets.all(17), children: [
    Container(padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(color: dark, borderRadius: BorderRadius.circular(27)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.campaign_outlined, color: lime), SizedBox(width: 9),
          Text('CAMPAIGN  /  CONTENT DELIVERY', style: TextStyle(color: lime, fontSize: 10, letterSpacing: 1))]),
        const SizedBox(height: 17), Text('Chiến dịch #${c.id}',
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8), Text('Nguồn truy cập: ${widget.link.source}',
          style: const TextStyle(color: Color(0xFFBBCDC5), fontSize: 12)),
        if (c.fromCache) ...[
          const SizedBox(height: 17), Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF3A4839), borderRadius: BorderRadius.circular(12)),
            child: Text(c.stale ? 'OFFLINE • Nội dung cache đã cũ' : 'CACHE • Nội dung đã lưu',
              style: const TextStyle(color: lime, fontWeight: FontWeight.bold, fontSize: 11))),
        ],
      ])),
    const SizedBox(height: 17),
    ClipRRect(borderRadius: BorderRadius.circular(22), child: SizedBox(height: 215, child: _picture(c))),
    if (c.photographer != null && c.photographer!.isNotEmpty)
      Padding(padding: const EdgeInsets.only(top: 7, left: 4),
        child: Text('Ảnh: ${c.photographer}', style: const TextStyle(color: Color(0xFF778278), fontSize: 11))),
    const SizedBox(height: 18),
    Container(padding: const EdgeInsets.all(23), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(23)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('STORY / NỘI DUNG', style: TextStyle(color: Color(0xFF53715F), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 14), Text(c.title, style: const TextStyle(fontSize: 23, height: 1.24, fontWeight: FontWeight.w900, color: dark)),
        const SizedBox(height: 14), Text(c.body, style: const TextStyle(height: 1.7, fontSize: 15, color: dark)),
      ])),
    const SizedBox(height: 17),
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(
      color: const Color(0xFFE9F3D4), borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ĐƯỜNG DẪN CHIẾN DỊCH', style: TextStyle(color: dark, fontSize: 11, fontWeight: FontWeight.w800)),
        const SizedBox(height: 9), SelectableText(widget.link.appUri, style: const TextStyle(color: dark, fontSize: 12)),
        const SizedBox(height: 13), Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: _copy, icon: const Icon(Icons.copy_outlined), label: const Text('Sao chép'))),
          const SizedBox(width: 9), Expanded(child: FilledButton.icon(onPressed: _share,
            style: FilledButton.styleFrom(backgroundColor: dark), icon: const Icon(Icons.share_outlined), label: const Text('Chia sẻ'))),
        ]),
      ])),
    const SizedBox(height: 15),
    Text('Cache cập nhật: ${c.cachedAt.toLocal()}', style: const TextStyle(color: Color(0xFF7B867B), fontSize: 11)),
    const SizedBox(height: 16),
    OutlinedButton.icon(onPressed: () => controller.load(forceRefresh: true),
      icon: const Icon(Icons.refresh_rounded), label: const Text('Tải mới từ API')),
  ]);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: controller, builder: (context, _) {
    return Scaffold(backgroundColor: const Color(0xFFF2F5EF),
      appBar: AppBar(title: const Text('Campaign story', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFFF2F5EF), surfaceTintColor: Colors.transparent,
        actions: [IconButton(onPressed: _share, icon: const Icon(Icons.share_rounded))]),
      body: controller.status == CampaignDetailStatus.loading
        ? const Center(child: CircularProgressIndicator(color: dark))
        : controller.status == CampaignDetailStatus.error || controller.status == CampaignDetailStatus.notFound
          ? _failed('Không tải được chiến dịch', controller.errorMessage ?? 'Không có dữ liệu.')
          : controller.campaign == null
            ? const Center(child: Text('Không có dữ liệu')) : _content(controller.campaign!),
    );
  });
}
