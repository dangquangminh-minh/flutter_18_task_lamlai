import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/auth_repository.dart';
import '../widgets/campus_auth_widgets.dart';


class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({
    super.key, required this.repository, required this.onVerified, });

  final AuthRepository repository;
  final VoidCallback onVerified;

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool loading = false;
  String? message;

  bool error = false;



  // reload tài khoản để xác định email đã được x.minh
  Future<void> _check() async {
    setState(() {
      loading = true;
      message = null;
    });

    try {
      final user = await widget.repository .reloadCurrentUser();

      if (user?.emailVerified == true) {
        widget.onVerified();
        return;
      }

      setState(() {
        error = true;
        message = 'Email vẫn chưa được xác minh. '
            'Hãy mở email và bấm liên kết '

            'Firebase gửi cho bạn.';
      });
    } catch (e) {
      setState(() {
        error = true;
        message = 'Không kiểm tra được: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }



  // gửi lại thư xác minh khi người dùng yêu cầu.
  Future<void> _resend() async {
    setState(() {
      loading = true;
      message = null;
    });

    try {
      await widget.repository .sendVerificationEmail();

      setState(() {
        error = false;
        message = 'Đã gửi lại email xác minh.';
      });
    } catch (e) {
      setState(() {
        error = true;
        message = 'Không gửi được email: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }


  @override
  Widget build( BuildContext context, ) {
    final user = widget.repository.currentUser;

    return Scaffold(backgroundColor: campusBackground,
      appBar: AppBar(backgroundColor: campusBackground, leading: IconButton(
        tooltip: 'Về trang chủ', onPressed: () => context.go('/'),
        icon: const Icon(Icons.home_rounded))), body: SafeArea( child: Center( child:
              SingleChildScrollView(
            padding: const EdgeInsets.all( 18, ), child: CampusCard( child: Column( children: [
                  Container( width: 82, height: 82, decoration: const BoxDecoration( color: campusMint,
                      shape: BoxShape.circle, ),
                    child: const Icon( Icons .mark_email_unread_outlined, size: 38, color: campusGreen,
                    ), ),

                  const SizedBox( height: 18, ),

                  const Text( 'Xác minh email', style: TextStyle( fontSize: 22, fontWeight:
                          FontWeight.bold, ), ),

                  const SizedBox( height: 7, ),

                  Text( 'Firebase đã gửi liên kết '
                    'xác minh tới\n'
                    '${user?.email ?? ''}', textAlign: TextAlign.center, style: const TextStyle( color:
                          Colors.black54, ), ),

                  const SizedBox( height: 18, ),

                  if (message != null)
                    Container( width: double.infinity, padding: const EdgeInsets.all( 12, ), decoration:
                          BoxDecoration(
                        color: error
                                ? const Color( 0xFFFFDAD6, )
                                : campusMint,
                        borderRadius: BorderRadius.circular( 12, ), ),
                      child: Text( message!, textAlign: TextAlign.center, ), ),

                  const SizedBox( height: 16, ),

                  SizedBox( width: double.infinity, height: 50, child: FilledButton.icon( style:
                          FilledButton.styleFrom(
                        backgroundColor: campusGreen, ),
                      onPressed: loading
                              ? null
                              : _check,
                      icon: const Icon( Icons.refresh, ), label: const Text( 'Tôi đã xác minh', ), ), ),

                  TextButton( onPressed: loading
                            ? null
                            : _resend,
                    child: const Text( 'Gửi lại email xác minh', ), ),

                  TextButton.icon( onPressed: loading
                            ? null
                            : widget.repository .logout,
                    icon: const Icon( Icons.logout, ), label: const Text( 'Đăng xuất', ), ), ], ), ), ),
        ), ), );
  }
}
