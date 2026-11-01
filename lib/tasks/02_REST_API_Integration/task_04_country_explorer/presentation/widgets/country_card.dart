import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/models/country_model.dart';
import '../country_palette.dart';


class CountryCard extends StatelessWidget {
  const CountryCard({super.key, required this.country, required this.onTap});

  final CountryModel country;
  final VoidCallback onTap;

  @override

  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(children: [
            Container(
              width: 72,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: countryMint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: country.flagUrl.isEmpty
                  ? Center(child: Text(country.flagEmoji, style: const TextStyle(fontSize: 35)))
                  : CachedNetworkImage(
                      imageUrl: country.flagUrl,
                      fit: BoxFit.cover,
                      // Ảnh cờ lỗi thì dùng emoji/icon dự phòng để UI không bị trống.
                      errorWidget: (_, _, _) => Center(
                        child: Text(country.flagEmoji, style: const TextStyle(fontSize: 30)),
                      ),
                    ),
            ),
            const SizedBox(width: 13),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(country.commonName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: countryInk)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.location_city_outlined, size: 14, color: countryMuted),
                  const SizedBox(width: 5),
                  Expanded(child: Text(country.capitalName, maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: countryMuted))),
                ]),
                const SizedBox(height: 6),
                Text(country.region.toUpperCase(),
                    style: const TextStyle(fontSize: 10, letterSpacing: 1,
                        color: countryTeal, fontWeight: FontWeight.bold)),
              ],
            )),
            const Icon(Icons.arrow_forward_ios_rounded, color: countryTeal, size: 15),
          ]),
        ),
      ),
    );
  }
}
