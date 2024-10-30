import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/src/widgets/profile_page.dart';
import 'package:app/src/widgets/sign_in_page.dart';

class ProfileWrapperPage extends StatefulWidget {
  const ProfileWrapperPage({super.key});

  @override
  State<ProfileWrapperPage> createState() => ProfileWrapperPageState();
}

class ProfileWrapperPageState extends State<ProfileWrapperPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (FirebaseAuth.instance.currentUser == null || !FirebaseAuth.instance.currentUser!.emailVerified) {
                return const SignInPage();
              } else {
                return const ProfilePage();
              }
            }));
  }
}
