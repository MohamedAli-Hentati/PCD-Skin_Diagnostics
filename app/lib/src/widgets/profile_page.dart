import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/src/widgets/sign_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (FirebaseAuth.instance.currentUser == null) {
          return SignPage();
        } else if (!FirebaseAuth.instance.currentUser!.emailVerified) {
          return SignPage();
        } else {
          return SafeArea(
              child: Center(
                  child: Column(children: [
            Text('Logged in as ${FirebaseAuth.instance.currentUser?.email}'),
            IconButton(
                onPressed: FirebaseAuth.instance.signOut,
                icon: Icon(Icons.logout))
          ])));
        }
      },
    ));
  }
}