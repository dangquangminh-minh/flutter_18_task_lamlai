import 'package:flutter/material.dart';

const campusGreen = Color(0xFF14715C);

const campusDarkGreen = Color(0xFF114F43);

const campusMint = Color(0xFFDDF5E8);

const campusBackground = Color(0xFFF3F8F5);


class CampusCard extends StatelessWidget {
  const CampusCard({
    super.key, required this.child, this.padding = const EdgeInsets.all(16), });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build( BuildContext context, ) {
    return Container( width: double.infinity, padding: padding, decoration: BoxDecoration( color:
            Colors.white,
        borderRadius: BorderRadius.circular( 20, ), boxShadow: const [
          BoxShadow( color: Color(0x10000000), blurRadius: 18, offset: Offset(0, 5), ), ], ),
      child: child, );
  }
}

class CampusHeader extends StatelessWidget {
  const CampusHeader({
    super.key, required this.title, required this.subtitle, });

  final String title;
  final String subtitle;

  @override
  Widget build( BuildContext context, ) {
    return Container( padding: const EdgeInsets.all( 18, ), decoration: BoxDecoration( color:
            campusGreen,
        borderRadius: BorderRadius.circular( 20, ), ),
      child: Row( children: [
          Container( width: 56, height: 56, decoration: const BoxDecoration( color: Color(0x22FFFFFF),
              shape: BoxShape.circle, ),
            child: const Icon( Icons.school_rounded, color: Colors.white, size: 30, ), ),
          const SizedBox( width: 12, ), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment
                      .start,
              children: [
                Container( padding: const EdgeInsets .symmetric( horizontal: 8, vertical: 3, ),
                  decoration: BoxDecoration( color: campusMint, borderRadius: BorderRadius .circular( 20,
                    ), ),
                  child: const Text( 'CỔNG THÔNG TIN SINH VIÊN', style: TextStyle( color:
                          campusDarkGreen,
                      fontWeight: FontWeight.bold, fontSize: 9, ), ), ),
                const SizedBox( height: 5, ), Text( title, style: const TextStyle( color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 20, ), ),
                Text( subtitle, style: const TextStyle( color: Colors.white70, fontSize: 11, ), ), ], ),
          ), ], ), );
  }
}
