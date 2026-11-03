import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'task_18_secure_travel_account/presentation/pages/task18_login_page.dart';


class Chapter6SignedInGuard extends StatelessWidget {
  const Chapter6SignedInGuard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == null) return const Task18LoginPage();
        return child;
      },
    );
  }
}
