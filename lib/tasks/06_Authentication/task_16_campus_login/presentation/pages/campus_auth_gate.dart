import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/auth_repository.dart';
import 'campus_auth_loading_page.dart';
import 'campus_auth_page.dart';
import 'campus_profile_page.dart';
import 'email_verification_page.dart';


class CampusAuthGate extends StatefulWidget {
  const CampusAuthGate({
    super.key, });

  @override
  State<CampusAuthGate> createState() => _CampusAuthGateState();
}

class _CampusAuthGateState extends State<CampusAuthGate> {
  final AuthRepository repository = AuthRepository();

  void _refreshVerification() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build( BuildContext context, ) {
    return StreamBuilder<User?>( stream: repository.authStateChanges, initialData:
          repository.currentUser,
      builder: (context, snapshot) {
        if (snapshot .connectionState == ConnectionState.waiting && repository.currentUser == null) {
          return const CampusAuthLoadingPage();
        }

        final user = repository.currentUser ?? snapshot.data;

        // chưa login
        if (user == null) {
          return CampusAuthPage( repository: repository, );
        }

        // đã login nhưng chưa verify
        if (!user.emailVerified) {
          return EmailVerificationPage( repository: repository, onVerified: _refreshVerification, );
        }

        // login vs verify
        return CampusProfilePage( repository: repository, );
      }, );
  }
}
