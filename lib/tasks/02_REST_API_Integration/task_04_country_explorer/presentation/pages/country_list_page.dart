import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../data/datasources/country_remote_data_source.dart';
import '../../data/repositories/country_repository.dart';
import '../../domain/models/country_model.dart';
import '../country_palette.dart';
import '../widgets/country_card.dart';
import 'country_detail_page.dart';

class CountryListPage extends StatefulWidget { 

  const CountryListPage({super.key});

  @override
  State<CountryListPage> createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  late final CountryRepository _repository;
  final _searchController = TextEditingController();

  List<CountryModel> _all = [];
  bool _loading = true;
  String? _error;
  
  String _query = '';
  String _region = 'Tất cả';

  String _sort = 'Tên A-Z';

  static const _regions = [
    'Tất cả', 'Asia', 'Europe', 'Africa', 'Americas', 'Oceania',
  ];

  @override
  // khởi tạo dio và repo một lần khi mở trag
  void initState() {
    super.initState();
    _repository = CountryRepository(
      remoteDataSource: CountryRemoteDataSource(
        dio: Dio(BaseOptions(connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 12))),
      ),
    );
    _load();
  }

  @override
  // xóa Text khi rời trang để tránh lãng phí tnguyen
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // bấm refresh và nút Thử lại khi lỗi mạng
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repository.getCountries();
      // Đảm bảo Widget còn tồn tại trước khi gọi setState sau request bất đồng bộ.
      if (!mounted) return;
      setState(() { _all = data; _loading = false; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _error = error.toString(); _loading = false; });
    }
  }

  // lọc theo tên và khu vực 
  List<CountryModel> get _visible {
    final keyword = _query.toLowerCase().trim();

    final list = _all.where((country) {
      final matchesText = country.commonName.toLowerCase().contains(keyword);
      final matchesRegion = _region == 'Tất cả' || country.region == _region;
      return matchesText && matchesRegion;
    }).toList();


    if (_sort == 'Dân số tăng') {
      list.sort((a, b) => a.population.compareTo(b.population));
    } else if (_sort == 'Dân số giảm') {

      list.sort((a, b) => b.population.compareTo(a.population));
    } else {
      list.sort((a, b) => a.commonName.compareTo(b.commonName));
    }
    return list;
  }

  // nhập từ khóa
  Widget _searchBar() => TextField(
    controller: _searchController,
    onChanged: (value) => setState(() => _query = value),
    decoration: InputDecoration(
      hintText: 'Tên quốc gia, ví dụ: Vietnam',
      hintStyle: const TextStyle(color: countryMuted, fontSize: 13),
      prefixIcon: const Icon(Icons.search_rounded, color: countryTeal),
      suffixIcon: _query.isEmpty ? null : IconButton(
        onPressed: () { _searchController.clear(); setState(() => _query = ''); },
        icon: const Icon(Icons.close_rounded),
      ),
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(17)),
    ),
  );


  Widget _empty(String title, String message, {VoidCallback? retry}) =>
    Container(
      width: double.infinity, padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(children: [

        const Icon(Icons.travel_explore_rounded, size: 49, color: countryTeal),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(color: countryInk, fontSize: 17,
            fontWeight: FontWeight.bold)),
        const SizedBox(height:  7 ),
        Text(message, textAlign: TextAlign.center,
            style: const TextStyle(color: countryMuted, height: 1.5)),
        if (retry != null) ...[
          const SizedBox(height: 15),
          FilledButton.icon(onPressed: retry, icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: FilledButton.styleFrom(backgroundColor: countryTeal)),
        ],
      ]),
    );

  @override
  // banner giới thiệu, tìm kiếm, chip khu vực, sx và ds kq
  Widget build(BuildContext context) {
    final items = _visible;
    return Scaffold(
      backgroundColor: countryCream,
      appBar: AppBar(
        backgroundColor: countryCream, foregroundColor: countryInk,
        title: const Text('Country Explorer', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Tải lại quốc gia')],
      ),
      // vuốt xuống để tải thêm
      body: RefreshIndicator(
        onRefresh: _load, color: countryTeal,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(17, 8, 17, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: countryInk,
                  borderRadius: BorderRadius.circular(26)),
              child: Row(children: [
                const Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DANH BẠ THẾ GIỚI', style: TextStyle(
                        color: Color(0xFF9CD5CD), letterSpacing: 1.5,
                        fontWeight: FontWeight.w800, fontSize: 10)),
                    SizedBox(height: 8),
                    Text('Mỗi quốc gia,\nmột câu chuyện.',
                        style: TextStyle(fontSize: 24, height: 1.2,
                            color: Colors.white, fontWeight: FontWeight.w900)),
                    SizedBox(height: 9),
                    Text('Tìm nhanh thủ đô, vùng lãnh thổ và dân số.',
                        style: TextStyle(color: Color(0xFFCFEBE5), fontSize: 12)),
                  ],
                )),
                Container(padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(color: const Color(0xFF266269),
                      borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.public_rounded, size: 43,
                      color: Color(0xFFBDF0DB))),
              ]),
            ),
            const SizedBox(height: 17),
            _searchBar(),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _regions.map((name) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(name), selected: _region == name,
                  onSelected: (_) => setState(() => _region = name),
                  selectedColor: countryMint, backgroundColor: Colors.white,
                  side: BorderSide.none,
                  labelStyle: TextStyle(color: _region == name ? countryTeal : countryMuted,
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
              )).toList()),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Text(_loading ? 'Đang tải quốc gia...' : '${items.length} quốc gia',
                  style: const TextStyle(fontSize: 18, color: countryInk,
                      fontWeight: FontWeight.w800))),
              DropdownButton<String>(
                value: _sort, underline: const SizedBox.shrink(),
                icon: const Icon(Icons.keyboard_arrow_down, color: countryTeal),
                items: const ['Tên A-Z', 'Dân số tăng', 'Dân số giảm']
                    .map((s) => DropdownMenuItem(value: s,
                        child: Text(s, style: const TextStyle(fontSize: 12,
                            color: countryInk)))).toList(),
                onChanged: (value) { if (value != null) setState(() => _sort = value); },
              ),
            ]),
            const SizedBox(height: 10),
            // Trong lúc chờ HTTP, dựng các khung chờ để người dùng biết ứng dụng đang tải.
            if (_loading) ...List.generate(5, (i) => Container(
              margin: const EdgeInsets.only(bottom: 12), height: 86,
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(20)),
              child: const Center(child: LinearProgressIndicator(
                  color: countryTeal, backgroundColor: countryMint)),
            ))

            else if (_error != null) _empty('Không tải được dữ liệu', _error!, retry: _load)
            else if (items.isEmpty) _empty('Không có kết quả',
            
                'Hãy thử từ khóa khác hoặc chọn lại khu vực.')
            // Tách từng hàng thành CountryCard và mở trang chi tiết bằng model đã có.
            else ...items.map((country) => CountryCard(
              country: country,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CountryDetailPage(country: country))),
            )),
          ],
        ),
      ),
    );
  }
}
