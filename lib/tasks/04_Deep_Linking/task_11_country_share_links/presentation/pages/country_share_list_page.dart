

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/country_share_repository.dart';
import '../../domain/models/country_share_model.dart';

import '../../services/country_share_link_parser.dart';

import '../controllers/country_share_list_controller.dart';


class CountryShareListPage extends StatefulWidget {
  const CountryShareListPage({super.key, required this.repository, this.region, this.openedFromDeepLink = false});
  final CountryShareRepository repository;
  final String? region;
  final bool openedFromDeepLink;
  @override
  State<CountryShareListPage> createState() => _CountryShareListPageState();
}

class _CountryShareListPageState extends State<CountryShareListPage> {
  static const night = Color(0xFF242447);
  static const violet = Color(0xFF6354C7);
  static const bg = Color(0xFFF6F5FB);
  late final CountryShareListController controller;
  final search = TextEditingController();
  final regions = <String?>[null, 'Asia', 'Europe', 'Africa', 'Americas', 'Oceania'];

  @override
  void initState() {
    super.initState();
    controller = CountryShareListController(repository: widget.repository)..load(region: widget.region);
  }

  @override
  void didUpdateWidget(covariant CountryShareListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi đang ở trang này mà nhận link region khác, tải lại dữ liệu theo region mới.
    if (widget.region != oldWidget.region) controller.load(region: widget.region);
  }

  @override
  void dispose() { search.dispose(); controller.dispose(); super.dispose(); }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: CountryShareLinkParser.buildListLink(controller.region)));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã chép liên kết danh sách')));
  }

  Future<void> _share() async {
    await SharePlus.instance.share(ShareParams(text: 'Danh sách quốc gia ${controller.region ?? 'toàn thế giới'}:\n${CountryShareLinkParser.buildListLink(controller.region)}'));
  }

  // Tạo route có query region để trạng thái lọc có thể được chia sẻ chính xác.

  void _setRegion(String? region) {
    search.clear();
    controller.setSearch('');
    // Truy cập qua router để query param luôn tương ứng với bộ lọc trong UI.
    context.pushReplacement(Uri(path: '/countries', queryParameters: {'region': ?region}).toString());
  }

  // dùng mã iso khi có, còn thiếu mã thì chuyển sang route country-name

  Widget _card(CountryShareModel c) => InkWell(
    onTap: () {
      if (CountryShareLinkParser.isValidCode(c.cca3)) {
        context.push('/country/${c.cca3}');
      } else {
        context.push(Uri(path: '/country-name', queryParameters: {'name':c.name}).toString());
      }
    },
    borderRadius: BorderRadius.circular(18),
    child: Container(margin: const EdgeInsets.only(bottom: 11), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFEBE8F7))),
      child: Row(children: [
        Container(width: 59, height: 59, alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFFEEEAFF), borderRadius: BorderRadius.circular(15)),
          child: Text(c.flagEmoji, style: const TextStyle(fontSize: 31))),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: night, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text('${c.capital}  •  ${c.region}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF77758A))),
          const SizedBox(height: 5),
          Text('Mã ${c.cca3.isNotEmpty ? c.cca3 : c.cca2} · ${c.population} dân',
            style: const TextStyle(fontSize: 10, color: violet)),
        ])),
        const Icon(Icons.arrow_outward_rounded, color: violet, size: 20),
      ]),
    ),
  );

  // Tách loading/error/empty rõ ràng; không biến lỗi API thành kết quả tìm kiếm rỗng.

  Widget _results() => AnimatedBuilder(animation: controller, builder: (context, _) {
    if (controller.status == CountryShareListStatus.loading || controller.status == CountryShareListStatus.initial) {
      return Column(children: List.generate(4, (_) => Container(height: 83, margin: const EdgeInsets.only(bottom: 11),
        decoration: BoxDecoration(color: const Color(0xFFEAE8F4), borderRadius: BorderRadius.circular(18)))));
    }
    if (controller.status == CountryShareListStatus.error) {
      return _message('Không tải được danh sách', controller.errorMessage ?? 'Đã có lỗi kết nối.', controller.retry);
    }
    final items = controller.filteredCountries;
    if (items.isEmpty) return _message('Không có kết quả', 'Hãy đổi khu vực hoặc từ khóa tìm kiếm.', () => _setRegion(null));
    return Column(children: items.map(_card).toList());
  });

  Widget _message(String title, String subtitle, VoidCallback retry) => Container(
    width: double.infinity, padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(children: [const Icon(Icons.public_off_rounded, size: 40, color: violet), const SizedBox(height: 10),
      Text(title, style: const TextStyle(color: night, fontWeight: FontWeight.bold)),
      const SizedBox(height: 7), Text(subtitle, textAlign: TextAlign.center),
      const SizedBox(height: 10), TextButton(onPressed: retry, child: const Text('Thử lại'))]),
  );

  @override
  // header, vùng chọn k.vực và ds
  Widget build(BuildContext context) => Scaffold(backgroundColor: bg,
    appBar: AppBar(title: const Text('Atlas Links', style: TextStyle(fontWeight: FontWeight.w900)),
      backgroundColor: bg, foregroundColor: night, surfaceTintColor: Colors.transparent,
      actions: [IconButton(tooltip: 'Chia sẻ bộ lọc', onPressed: _share, icon: const Icon(Icons.share_rounded))]),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(17), children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2C2858), Color(0xFF655AC9)]),
        borderRadius: BorderRadius.circular(27)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.auto_stories_rounded, color: Color(0xFFDCD8FF)), SizedBox(width: 9),
            Text('COUNTRY COLLECTION  •  TASK 11', style: TextStyle(color: Color(0xFFE5DFFF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: .7))]),
          const SizedBox(height: 16),
          const Text('Thế giới trong\nmột đường link.', style: TextStyle(color: Colors.white, fontSize: 28, height: 1.16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Text('Lọc theo châu lục, tìm quốc gia và gửi link để mở đúng kết quả.',
          
            style: TextStyle(color: Color(0xFFE4E0FC), height: 1.4, fontSize: 12)),
          const SizedBox(height: 17),
          Row(children: [Expanded(child: Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(13)),
            child: Text(CountryShareLinkParser.buildListLink(controller.region),
              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)))),
            const SizedBox(width: 8), IconButton.filledTonal(onPressed: _copy,
              icon: const Icon(Icons.copy_all_rounded, color: night))]),
        ])),
      const SizedBox(height: 24),
      const Text('Chọn khu vực', style: TextStyle(color: night, fontWeight: FontWeight.w800, fontSize: 17)),
      const SizedBox(height: 10),
      SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal,
        itemCount: regions.length, separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, i) {
          final region = regions[i]; final selected = region == controller.region;
          return ChoiceChip(label: Text(region ?? 'Tất cả'), selected: selected, onSelected: (_) => _setRegion(region),
            selectedColor: const Color(0xFFDCD6FE), backgroundColor: Colors.white,
            labelStyle: TextStyle(color: selected ? violet : night, fontSize: 12, fontWeight: FontWeight.w600),
            side: const BorderSide(color: Color(0xFFE1DEF2)));
        })),
      const SizedBox(height: 18),


      TextField(controller: search, onChanged: controller.setSearch,
        decoration: InputDecoration(hintText: 'Tên, thủ đô hoặc mã quốc gia...', prefixIcon: const Icon(Icons.search_rounded, color: violet),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
      const SizedBox(height: 19),
      AnimatedBuilder(animation: controller, builder: (_, _) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Danh sách quốc gia', style: TextStyle(color: night, fontWeight: FontWeight.w800, fontSize: 18)),
        Text('${controller.filteredCountries.length} địa điểm', style: const TextStyle(color: violet, fontSize: 12)),
      ])),
      const SizedBox(height: 12),
      _results(),
    ])),
  );
}
