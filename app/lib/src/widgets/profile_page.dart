import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(Theme.of(context).primaryColor);
    final hslDark = hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0));
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
            elevation: 20,
            shadowColor: Colors.black,
          ),
          body: Column(
            children: [
              Container(
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(blurRadius: 20, color: Colors.black)
                      ],
                      gradient: LinearGradient(
                          colors: [
                            hslDark.toColor(),
                            Theme.of(context).primaryColor
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(right: 50),
                            child: Container(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(blurRadius: 20, color: Colors.black)
                              ]),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(15), // Image border
                                child: SizedBox.fromSize(
                                  size: Size.fromRadius(60), // Image radius
                                  child: (FirebaseAuth
                                              .instance.currentUser!.photoURL ==
                                          null)
                                      ? Image.asset(
                                          'lib/assets/images/profile.png')
                                      : Image.network(
                                          isAntiAlias: true,
                                          FirebaseAuth
                                              .instance.currentUser!.photoURL!,
                                          fit: BoxFit.cover),
                                ),
                              ),
                            )),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Welcome',
                              style: TextStyle(
                                shadows: [
                                  BoxShadow(blurRadius: 50, color: Colors.black)
                                ],
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              FirebaseAuth.instance.currentUser!.displayName ??
                                  'User',
                              style: TextStyle(
                                shadows: [
                                  BoxShadow(blurRadius: 50, color: Colors.black)
                                ],
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      ])),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                child: Card(
                  elevation: 10,
                  child: ListTile(
                      tileColor: Colors.grey.shade300,
                      leading: Icon(Icons.history),
                      trailing: Icon(Icons.keyboard_arrow_right_outlined),
                      title: Text('History'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                child: Card(
                  elevation: 10,
                  child: ListTile(
                      tileColor: Colors.grey.shade300,
                      leading: Icon(Icons.history),
                      trailing: Icon(Icons.keyboard_arrow_right_outlined),
                      title: Text('History'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                child: Card(
                  elevation: 10,
                  child: ListTile(
                      tileColor: Colors.grey.shade300,
                      leading: Icon(Icons.history),
                      trailing: Icon(Icons.keyboard_arrow_right_outlined),
                      title: Text('History'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                child: Card(
                  elevation: 10,
                  child: ListTile(
                      tileColor: Colors.grey.shade300,
                      leading: Icon(Icons.logout),
                      trailing: Icon(Icons.keyboard_arrow_right_outlined),
                      title: Text('Logout'),
                      onTap: FirebaseAuth.instance.signOut,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                child: Card(
                  elevation: 10,
                  child: ListTile(
                      tileColor: Colors.grey.shade300,
                      leading: Icon(Icons.close),
                      trailing: Icon(Icons.keyboard_arrow_right_outlined),
                      title: Text('Delete account'),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                    'Are you sure you want to delete your account?'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('No')),
                                  TextButton(
                                      onPressed: () async {
                                        await FirebaseAuth.instance.currentUser
                                            ?.delete();
                                        Navigator.pop(context);
                                      },
                                      child: Text('Yes'))
                                ],
                              );
                            });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      )),
                ),
              )
            ],
          )),
    );
  }
}
