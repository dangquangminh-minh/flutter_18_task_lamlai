

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/country_share_repository.dart';

import '../../domain/models/country_share_model.dart';

import '../../services/country_share_link_parser.dart';
import '../controllers/country_share_detail_controller.dart';


class CountryShareDetailPage extends StatefulWidget {
  const CountryShareDetailPage({super.key, required this.repository, this.code, this.name, this.openedFromDeepLink = false});
  final CountryShareRepository repository;
  final String? code;
  final String? name;
  final bool openedFromDeepLink;
  @override
  State<CountryShareDetailPage> createState() => _CountryShareDetailPageState();
}

class _CountryShareDetailPageState extends State<CountryShareDetailPage> {
  static const night = Color(0xFF242447);
  static const violet = Color(0xFF6354C7);
  late CountryShareDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = CountryShareDetailController(repository: widget.repository, code: widget.code, name: widget.name)..load();
  }

  @override
  // if nhận uri mới trong khi page vẫn t.tại,tải lại qg theo tham số mới
  void didUpdateWidget(covariant CountryShareDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code || oldWidget.name != widget.name) {
      controller.dispose();
      controller = CountryShareDetailController(repository: widget.repository, code: widget.code, name: widget.name)..load();
    }
  }

  @override
  void dispose() { controller.dispose(); super.dispose(); }



  String _link(CountryShareModel c) => CountryShareLinkParser.buildCountryLink(code: c.cca3, name: c.name);

  Future<void> _copy(CountryShareModel c) async {
    await Clipboard.setData(ClipboardData(text: _link(c)));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép liên kết quốc gia')));
  }

  Future<void> _share(CountryShareModel c) async {
    await SharePlus.instance.share(ShareParams(text: '${c.flagEmoji} ${c.name}\n${_link(c)}'));
  }

  // widget thôg tin dùng lại cho thủ đô, d.số, tiền tệ và múi giờ

  Widget _item(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
      color: const Color(0xFFF0EEFC), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: violet)),
      const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Color(0xFF79788C), fontSize: 11)),
        const SizedBox(height: 3), Text(value.isEmpty ? 'Chưa có dữ liệu' : value,
          style: const TextStyle(color: night, fontSize: 13, fontWeight: FontWeight.w700)),
      ]))]),
  );

  Widget _error(String title, String description) => Center(child: Padding(padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.travel_explore_outlined, size: 58, color: violet),
      const SizedBox(height: 10), Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), Text(description, textAlign: TextAlign.center),
      const SizedBox(height: 16), FilledButton(onPressed: controller.load,
        style: FilledButton.styleFrom(backgroundColor: violet), child: const Text('Thử lại')),
    ])));

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: controller, builder: (context, _) {
    final c = controller.country;
    return Scaffold(backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(title: const Text('Hồ sơ quốc gia', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFFF6F5FB), foregroundColor: night, surfaceTintColor: Colors.transparent,
        actions: [if (c != null) IconButton(onPressed: () => _share(c), icon: const Icon(Icons.ios_share_rounded))]),
      // khi lỗi hoặc 404,thông báo và nút retry
      body: controller.status == CountryShareDetailStatus.loading
        ? const Center(child: CircularProgressIndicator(color: violet))
        : controller.status == CountryShareDetailStatus.error || controller.status == CountryShareDetailStatus.notFound
          ? _error('Không mở được quốc gia', controller.errorMessage ?? 'Không có thông tin phù hợp.')
          : c == null ? const Center(child: Text('Không có dữ liệu')) : ListView(
            padding: const EdgeInsets.all(16), children: [
              Container(padding: const EdgeInsets.all(23), decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF27234E), Color(0xFF675AC3)]),
                borderRadius: BorderRadius.circular(27)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('ATLAS  /  COUNTRY PROFILE', style: TextStyle(color: Color(0xFFD7D1FF), fontSize: 11, letterSpacing: 1)),
                  const SizedBox(height: 16), Text(c.flagEmoji, style: const TextStyle(fontSize: 65)),
                  const SizedBox(height: 8), Text(c.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28)),
                  const SizedBox(height: 6), Text(c.officialName.isEmpty ? c.region : c.officialName,
                    style: const TextStyle(color: Color(0xFFE1DCF9), height: 1.4, fontSize: 12)),
                  const SizedBox(height: 17), Wrap(spacing: 8, children: [
                    Chip(label: Text(c.region), backgroundColor: const Color(0xFFEEEAFB)),
                    Chip(label: Text('ISO ${c.cca3}'), backgroundColor: const Color(0xFFEEEAFB)),
                  ]),
                ])),
              const SizedBox(height: 20),
              const Text('Thông tin điểm đến', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: night)),
              const SizedBox(height: 12),
              _item(Icons.location_city_outlined, 'Thủ đô', c.capital),


              const SizedBox(height: 10),
              _item(Icons.groups_outlined, 'Dân số', '${c.population}'),
              const SizedBox(height: 10),
              _item(Icons.map_outlined, 'Tiểu khu vực', c.subregion),
              const SizedBox(height: 10),
              _item(Icons.language_outlined, 'Ngôn ngữ', c.languages),
              const SizedBox(height: 10),
              _item(Icons.payments_outlined, 'Tiền tệ', c.currency),

              
              const SizedBox(height: 10),
              _item(Icons.schedule_rounded, 'Múi giờ', c.timezone),
              const SizedBox(height: 18),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
                color: const Color(0xFFEAE7FD), borderRadius: BorderRadius.circular(19)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('CHIA SẺ ĐIỂM ĐẾN', style: TextStyle(color: violet, fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8), SelectableText(_link(c), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12), Row(children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () => _copy(c), icon: const Icon(Icons.copy_rounded), label: const Text('Sao chép'))),
                    const SizedBox(width: 9), Expanded(child: FilledButton.icon(onPressed: () => _share(c),
                      style: FilledButton.styleFrom(backgroundColor: violet), icon: const Icon(Icons.share_outlined), label: const Text('Chia sẻ'))),
                  ]),
                ])),
            ]),
    );
  });
}
