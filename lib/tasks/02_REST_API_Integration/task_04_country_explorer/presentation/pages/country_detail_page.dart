import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/models/country_model.dart';
import '../country_palette.dart';


class CountryDetailPage extends StatelessWidget {
  const CountryDetailPage({super.key, required this.country});
  final CountryModel country;

  // dấu phân cách
  String _population(int value) => value.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.',
  );

  // 1 hàng thông tin 
  Widget _detailLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(11),

            decoration: BoxDecoration(color: countryMint, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: countryTeal)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, color: countryMuted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, color: countryInk, fontWeight: FontWeight.w700)),
        ])),
      ]),
    );
  }

  @override
  

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: countryCream,
      appBar: AppBar(backgroundColor: countryCream, foregroundColor: countryInk,
          title: const Text('Hồ sơ quốc gia', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: countryInk, borderRadius: BorderRadius.circular(28)),
          child: Column(children: [
            Container(
              width: double.infinity, height: 175, padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
              child: country.flagUrl.isEmpty
                  ? Center(child: Text(country.flagEmoji, style: const TextStyle(fontSize: 75)))
                  : CachedNetworkImage(imageUrl: country.flagUrl, fit: BoxFit.contain,
                      // mạng lỗi hoặc đường dẫn ảnh sai thì h.thị emoji cờ thay vì một khung ảnh trống
                      errorWidget: (_, _, _) => Center(child: Text(country.flagEmoji,
                          style: const TextStyle(fontSize: 75)))),
            ),
            const SizedBox(height: 18),
            Text(country.commonName, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(country.code.isEmpty ? country.region : '${country.code}  •  ${country.region}',
                style: const TextStyle(color: Color(0xFFC3EAE1))),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Thông tin cơ bản',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: countryInk)),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
          child: Column(children: [
            _detailLine(Icons.location_city_outlined, 'Thủ đô', country.capitalName),
            const Divider(height: 1),
            _detailLine(Icons.public_rounded, 'Khu vực', country.region),

            const Divider(height: 1),
            _detailLine(Icons.explore_outlined, 'Tiểu vùng', country.subregion),

            
            const Divider(height: 1),
            _detailLine(Icons.groups_outlined, 'Dân số', '${_population(country.population)} người'),
          ]),
        ),
      ]),
    );
  }
}
