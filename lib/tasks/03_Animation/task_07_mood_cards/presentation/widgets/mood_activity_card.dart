
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/activity_model.dart';
import 'activity_visuals.dart';
import 'favorite_button.dart';

class MoodActivityCard extends StatefulWidget {
  const MoodActivityCard({super.key, required this.activity,
    required this.isFavorite, required this.onFavorite, required this.onOpen,
    this.featured = false});
  final ActivityModel activity;
  final bool isFavorite;
  final VoidCallback onFavorite, onOpen;
  final bool featured;
  @override
  State<MoodActivityCard> createState() => _MoodActivityCardState();
}

class _MoodActivityCardState extends State<MoodActivityCard> {
  bool expanded = false;
  static const green = Color(0xFF146B58);

  @override
// giúp phần c.tiết nở ra/thu lại không giật bố cục
  Widget build(BuildContext context) {
    final item = widget.activity;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x120D342F), blurRadius: 23, offset: Offset(0, 10))]),
      child: ClipRRect(borderRadius: BorderRadius.circular(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.featured)
          
            GestureDetector(onTap: widget.onOpen,
              child: Hero(tag: 'activity_image_${item.id}',
                child: ActivityVisuals.cover(item.type, height: 184))),
          Padding(padding: const EdgeInsets.all(18), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFE4F5EF), borderRadius: BorderRadius.circular(13)),
                  child: Icon(ActivityVisuals.icon(item.type), color: green)),
                const SizedBox(width: 10),


                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.typeLabel.toUpperCase(), style: const TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  Text(item.participantLabel, style: const TextStyle(color: Color(0xFF738A80), fontSize: 12)),
                ])),
                FavoriteButton(isFavorite: widget.isFavorite, onPressed: widget.onFavorite),
              ]),
              const SizedBox(height: 13),
              Text(item.activity, style: TextStyle(fontSize: widget.featured ? 21 : 18,
                fontWeight: FontWeight.w800, color: const Color(0xFF173C32), height: 1.28)),
              const SizedBox(height: 14),
              Wrap(spacing: 7, runSpacing: 7, children: [
                _chip(Icons.payments_outlined, item.priceLabel),
                _chip(Icons.schedule_outlined, item.durationLabel),
              ]),

              AnimatedSize(duration: const Duration(milliseconds: 330),
                curve: Curves.easeInOut, alignment: Alignment.topCenter,
                child: expanded ? Padding(padding: const EdgeInsets.only(top: 14),
                  child: Container(width: double.infinity, padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF0F8F4), borderRadius: BorderRadius.circular(15)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _info('Khả năng tiếp cận', item.accessibilityLabel),
                      const SizedBox(height: 6),
                      _info('Số người tham gia', item.participantLabel),
                      const SizedBox(height: 6),
                      _info('Thân thiện trẻ em', item.kidFriendly ? 'Có' : 'Không xác định / không'),


                    ])),
                ) : const SizedBox.shrink()),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () { HapticFeedback.selectionClick(); setState(() => expanded = !expanded); },
                  icon: AnimatedRotation(turns: expanded ? .5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded)),
                  label: Text(expanded ? 'Thu gọn' : 'Mở rộng'),
                )),
                const SizedBox(width: 10),
                Expanded(child: FilledButton.icon(onPressed: widget.onOpen,
                  style: FilledButton.styleFrom(backgroundColor: green),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Chi tiết'))),
              ]),
            ],
          )),
        ])),
    );
  }
  Widget _chip(IconData icon, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(color: const Color(0xFFF3F6F3), borderRadius: BorderRadius.circular(11)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: green), const SizedBox(width: 5),
      Text(value, style: const TextStyle(color: Color(0xFF38554B), fontSize: 11, fontWeight: FontWeight.w600)),
    ]));
  Widget _info(String label, String value) => Text('$label: $value',
    style: const TextStyle(fontSize: 12, color: Color(0xFF375449), height: 1.5));
}
