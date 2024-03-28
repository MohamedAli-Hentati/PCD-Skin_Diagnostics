import 'package:app/src/widgets/history_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/src/utils/color_utils.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    dynamic profileImage;
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
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                      boxShadow: [BoxShadow(blurRadius: 25, color: Colors.grey)],
                      color: Colors.white,
                      shape: BoxShape.circle),
                  margin: const EdgeInsets.only(top: 30),
                  child: Stack(
                    children: [
                      CircleAvatar(radius: 50, backgroundImage: profileImage),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          height: 27.5,
                          width: 27.5,
                          decoration: const BoxDecoration(
                            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.grey)],
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            widthFactor: 17.5,
                            heightFactor: 17.5,
                            child: Icon(
                              Icons.edit_outlined,
                              size: 17.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  FirebaseAuth.instance.currentUser!.displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(FirebaseAuth.instance.currentUser!.email!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    )),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(overlayColor: MaterialStateProperty.resolveWith((states) {
                      return darken(Theme.of(context).colorScheme.primary);
                    }), backgroundColor: MaterialStateProperty.resolveWith((states) {
                      return Theme.of(context).colorScheme.primary;
                    })),
                    child: const SizedBox(
                      height: 40,
                      width: 175,
                      child: Center(
                        child: Text('Get advice from experts',
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
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ListTile(
                        tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.045),
                        leading: const Icon(Icons.shield_outlined),
                        trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                        title: const Text('Privacy'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ListTile(
                        tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.045),
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
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ListTile(
                        tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.045),
                        leading: const Icon(Icons.settings),
                        trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                        title: const Text('Settings'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ListTile(
                        tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.045),
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
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ListTile(
                        tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.045),
                        leading: const Icon(Icons.remove_circle_outline),
                        trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                        title: const Text('Delete account'),
                        onTap: () {
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
                                        onPressed: () {
                                          FirebaseAuth.instance.currentUser?.delete();
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Yes'))
                                  ],
                                );
                              });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
