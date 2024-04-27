import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app/src/widgets/history_page.dart';
import 'package:app/src/widgets/privacy_page.dart';
import 'package:app/src/widgets/settings_page.dart';
import 'package:app/src/widgets/chat_bot_page.dart';
import 'package:app/src/utils/color_utils.dart';
import 'package:app/src/components/dialog_components.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  dynamic profileImage;

  void deleteAccount() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Are you sure you want to delete your account?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No')),
              TextButton(
                  onPressed: () async {
                    switch (FirebaseAuth.instance.currentUser!.providerData[0].providerId) {
                      case 'password':
                        Navigator.pop(context);
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              final passwordController = TextEditingController();
                              return AlertDialog(
                                title: const Text('Enter your password:'),
                                content: TextField(
                                  controller: passwordController,
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () async {
                                        try {
                                          await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
                                              EmailAuthProvider.credential(
                                                  email: FirebaseAuth.instance.currentUser!.email!,
                                                  password: passwordController.text));
                                          await deleteUserData();
                                          await FirebaseAuth.instance.currentUser?.delete();
                                          Navigator.pop(context);
                                          showMessageDialog(context: context, message: 'Your account has been deleted.');
                                        } on Exception {
                                          Navigator.pop(context);
                                          showMessageDialog(context: context, message: 'Wrong password.');
                                        }
                                      },
                                      child: const Text('Confirm'))
                                ],
                              );
                            });
                      case 'google.com':
                        try {
                          final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                          final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
                          final credential = GoogleAuthProvider.credential(
                            accessToken: googleAuth?.accessToken,
                            idToken: googleAuth?.idToken,
                          );
                          await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
                          await deleteUserData();
                          await FirebaseAuth.instance.currentUser?.delete();
                          Navigator.pop(context);
                          showMessageDialog(context: context, message: 'Your account has been deleted.');
                        } on Exception {
                          Navigator.pop(context);
                          showMessageDialog(context: context, message: 'Sorry, something went wrong.');
                        }
                      case 'facebook.com':
                        try {
                          final LoginResult loginResult = await FacebookAuth.instance.login();
                          final OAuthCredential credential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
                          await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
                          await deleteUserData();
                          await FirebaseAuth.instance.currentUser?.delete();
                          Navigator.pop(context);
                          showMessageDialog(context: context, message: 'Your account has been deleted.');
                        } on Exception {
                          Navigator.pop(context);
                          showMessageDialog(context: context, message: 'Sorry, something went wrong.');
                        }
                    }
                  },
                  child: const Text('Yes'))
            ],
          );
        });
  }

  Future<void> deleteUserData() async {
    final historyQuery =
        await FirebaseFirestore.instance.collection('history').where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    final userDocument = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
    final listResult = await FirebaseStorage.instance.ref('users/${FirebaseAuth.instance.currentUser!.uid}').listAll();
    for (var item in listResult.items) {
      item.delete();
    }
    for (var document in historyQuery.docs) {
      document.reference.delete();
    }
    userDocument.delete();
  }

  void changePhoto() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      final imageStorageRef = FirebaseStorage.instance.ref().child('users/${FirebaseAuth.instance.currentUser!.uid}/profile.png');
      await imageStorageRef.putFile(File(image!.path));
      await FirebaseAuth.instance.currentUser!.updatePhotoURL(await imageStorageRef.getDownloadURL());
      setState(() {
        profileImage = NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!);
      });
    } on Exception {
      showMessageDialog(context: context, message: 'Sorry, something went wrong.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser!.photoURL == null) {
      profileImage = const AssetImage('lib/assets/images/profile.png');
    } else {
      profileImage = NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      boxShadow: [BoxShadow(blurRadius: 20, color: Colors.grey.shade600)],
                      color: Colors.white,
                      shape: BoxShape.circle),
                  margin: const EdgeInsets.only(top: 20),
                  child: Stack(
                    children: [
                      CircleAvatar(radius: 50, backgroundImage: profileImage),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: 27.5,
                          height: 27.5,
                          child: IconButton(
                            padding: const EdgeInsets.all(0.0),
                            style: IconButton.styleFrom(
                              elevation: 5,
                              shadowColor: Colors.grey,
                              backgroundColor: Colors.white,
                            ),
                            iconSize: 17.5,
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: changePhoto,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  FirebaseAuth.instance.currentUser!.displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(FirebaseAuth.instance.currentUser!.email!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    )),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ChatBotPage()));
                    },
                    style: ButtonStyle(overlayColor: MaterialStateProperty.resolveWith((states) {
                      return darken(Theme.of(context).colorScheme.primary);
                    }), backgroundColor: MaterialStateProperty.resolveWith((states) {
                      return Theme.of(context).colorScheme.primary;
                    })),
                    child: const SizedBox(
                      height: 40,
                      width: 175,
                      child: Center(
                        child: Text('Chat with our skin expert',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ListTile(
                        tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.010),
                        leading: const Icon(Icons.manage_accounts),
                        trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                        title: const Text('Settings'),
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) => const SettingsPage()))
                              .then((value) => setState(() {}));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ListTile(
                        tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.010),
                        leading: const Icon(Icons.history),
                        trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                        title: const Text('History'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HistoryPage()));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ListTile(
                        tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.010),
                        leading: const Icon(Icons.shield_outlined),
                        trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                        title: const Text('Privacy'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PrivacyPage()));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ListTile(
                        tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.010),
                        leading: const Icon(Icons.logout),
                        trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                        title: const Text('Logout'),
                        onTap: FirebaseAuth.instance.signOut,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ListTile(
                        tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.010),
                        leading: const Icon(Icons.remove_circle_outline),
                        trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                        title: const Text('Delete account'),
                        onTap: deleteAccount,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                  ),
                ),
                const SizedBox(height: 5)
              ],
            ),
          )
        ],
      ),
    );
  }
}
