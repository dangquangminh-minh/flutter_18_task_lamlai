import 'package:flutter/material.dart';

import '../widgets/campus_auth_widgets.dart';

class CampusAuthLoadingPage extends StatelessWidget {
  const CampusAuthLoadingPage({
    super.key, });

  @override
  Widget build( BuildContext context, ) {
    return Scaffold( backgroundColor: campusBackground, body: SafeArea( child: Padding( padding:
              const EdgeInsets.all(
            18, ),
          child: Column( children: [
              const SizedBox( height: 30, ),

              const CampusHeader( title: 'Campus Portal', subtitle: 'Firebase Authentication', ),

              const SizedBox( height: 18, ),

              Expanded( child: Center( child: CampusCard( child: Column( mainAxisSize: MainAxisSize .min,
                      children: [
                        Container( width: 90, height: 90, decoration: BoxDecoration( color: campusMint,
                            shape: BoxShape.circle, ),
                          child: const Padding( padding: EdgeInsets.all( 18, ), child:
                                CircularProgressIndicator(
                              color: campusGreen, strokeWidth: 5, ), ), ),
                        const SizedBox( height: 20, ), const Text( 'Đang kiểm tra phiên đăng nhập...',
                          textAlign: TextAlign.center, style: TextStyle( fontWeight: FontWeight.bold,
                            fontSize: 18, ), ),
                        const SizedBox( height: 6, ), const Text( 'Đang kết nối Firebase '
                          'Authentication và kiểm tra '
                          'trạng thái tài khoản.', textAlign: TextAlign.center, style: TextStyle( color:
                                Colors.black54, ), ),
                        const SizedBox( height: 22, ), const _LoadingStep( icon: Icons .lock_outline,
                          text: 'Kiểm tra Firebase Auth', ),
                        const _LoadingStep( icon: Icons .verified_user_outlined, text:
                              'Kiểm tra email xác minh', ),
                        const _LoadingStep( icon: Icons .person_outline, text:
                              'Chuẩn bị hồ sơ sinh viên', ), ], ), ), ), ), ], ), ), ), );
  }
}

class _LoadingStep extends StatelessWidget {
  const _LoadingStep({
    required this.icon, required this.text, });

  final IconData icon;
  final String text;

  @override
  Widget build( BuildContext context, ) {
    return Padding( padding: const EdgeInsets.symmetric( vertical: 6, ), child: Row( children: [
          Icon( icon, color: campusGreen, size: 20, ), const SizedBox( width: 10, ), Text( text, style:
                const TextStyle(
              fontSize: 13, ), ), ], ), );
  }
}
