import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'task17_social_login_page.dart';
import 'task17_social_profile_page.dart';

import '../../data/repositories/task17_auth_repository.dart';



class Task17SocialAuthGate extends StatefulWidget {
  const Task17SocialAuthGate({
    super.key, });

  @override
  State<Task17SocialAuthGate> createState()=> _Task17SocialAuthGateState();
}

class _Task17SocialAuthGateState extends State<Task17SocialAuthGate> {
  final Task17AuthRepository repository= Task17AuthRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>( stream:repository.authStateChanges, initialData:repository.currentUser,
      builder:(context,snapshot) {
        if(snapshot.connectionState== ConnectionState.waiting && repository.currentUser==null) {
          return const Scaffold( body:Center( child:CircularProgressIndicator(), ), );
        }

        final user= repository.currentUser ?? snapshot.data;

        if(user==null) {
          return Task17SocialLoginPage( repository:repository, );
        }

        return Task17SocialProfilePage( repository:repository, user:user, );
      }, );
  }
}
