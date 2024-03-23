import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/src/widgets/sign_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (FirebaseAuth.instance.currentUser == null) {
          return SignScreen();
        } else if (!FirebaseAuth.instance.currentUser!.emailVerified) {
          return SignScreen();
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