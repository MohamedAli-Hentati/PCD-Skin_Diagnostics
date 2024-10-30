import 'package:flutter/material.dart';
import 'package:app/src/utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/src/components/dialog_components.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  String displayName = FirebaseAuth.instance.currentUser!.displayName!;
  String age = 'Loading...';
  String gender = 'Loading...';
  String skinTone = 'Loading...';
  String skinType = 'Loading...';

  @override
  void initState() {
    super.initState();
    final document = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
    document.get().then((documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data()!;
        setState(() {
          displayName = FirebaseAuth.instance.currentUser!.displayName!;
          age = data['age'] ?? 'Not set';
          gender = data['gender'] ?? 'Not set';
          skinTone = data['skin_tone'] ?? 'Not set';
          skinType = data['skin_type'] ?? 'Not set';
        });
      } else {
        setState(() {
          age = 'Not set';
          gender = 'Not set';
          skinTone = 'Not set';
          skinType = 'Not set';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                      title: const Text('Display name'),
                      subtitle: Text(displayName),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.05),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      onTap: () {
                        final controller = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Center(
                              child: AlertDialog(
                                title: const Text('Change your display name:'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(hintText: 'Enter new display name'),
                                    ),
                                    const SizedBox(height: 10),
                                    RichText(
                                      text: TextSpan(
                                        style: DefaultTextStyle.of(context).style,
                                        children: const [
                                          WidgetSpan(
                                            child: Icon(
                                              Icons.info_outline,
                                              size: 12,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' Your display name must be at least 3 characters long.',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Save'),
                                    onPressed: () {
                                      if (controller.text.length > 2) {
                                        FirebaseAuth.instance.currentUser!.updateDisplayName(controller.text).then((value) {
                                          Navigator.of(context, rootNavigator: true).pop();
                                          setState(() {
                                            displayName = FirebaseAuth.instance.currentUser!.displayName!;
                                          });
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 5),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                      title: const Text('Password'),
                      subtitle: const Text('••••••••'),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.05),
                      visualDensity: VisualDensity.compact,
                      enabled: FirebaseAuth.instance.currentUser!.providerData[0].providerId == 'password',
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      onTap: () {
                        final oldPasswordController = TextEditingController();
                        final newPasswordController = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Center(
                              child: AlertDialog(
                                title: const Text('Change your password:'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: oldPasswordController,
                                      decoration: const InputDecoration(hintText: 'Enter old password'),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: newPasswordController,
                                      decoration: const InputDecoration(hintText: 'Enter new password'),
                                    ),
                                    const SizedBox(height: 10),
                                    RichText(
                                      text: TextSpan(
                                        style: DefaultTextStyle.of(context).style,
                                        children: const [
                                          WidgetSpan(
                                            child: Icon(
                                              Icons.info_outline,
                                              size: 12,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' Your new password must be at least 8 characters long.',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Save'),
                                    onPressed: () async {
                                      if (newPasswordController.text.length > 7) {
                                        FirebaseAuth.instance.currentUser!
                                            .reauthenticateWithCredential(EmailAuthProvider.credential(
                                                email: FirebaseAuth.instance.currentUser!.email!,
                                                password: oldPasswordController.text))
                                            .then((value) {
                                          FirebaseAuth.instance.currentUser!.updatePassword(newPasswordController.text).then((value) {
                                            Navigator.of(context, rootNavigator: true).pop();
                                            showMessageDialog(context: context, message: 'Your password was changed.');
                                          });
                                        }).catchError((exception) {
                                          Navigator.of(context, rootNavigator: true).pop();
                                          if (exception.code == 'wrong-password') {
                                            showMessageDialog(context: context, message: 'Wrong password.');
                                          } else {
                                            showMessageDialog(context: context, message: 'Sorry, an error has occurred.');
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
              Text(
                'Personal information',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: const [
                    WidgetSpan(
                      child: Icon(
                        Icons.info_outline,
                        size: 12,
                      ),
                    ),
                    TextSpan(
                      text: ' Providing more relevant information can help us provide better results.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                      title: const Text('Age'),
                      subtitle: Text(age),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.05),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      onTap: () {
                        final controller = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Center(
                              child: AlertDialog(
                                title: const Text('Set your age:'),
                                content: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: controller,
                                  decoration: const InputDecoration(hintText: 'Enter your age'),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Save'),
                                    onPressed: () {
                                      final inputAge = int.parse(controller.text);
                                      if (0 < inputAge && inputAge < 200) {
                                        final document =
                                            FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
                                        document.set({'age': controller.text}, SetOptions(merge: true)).then((value) {
                                          setState(() {
                                            age = controller.text;
                                          });
                                          Navigator.of(context, rootNavigator: true).pop();
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 5),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                      title: const Text('Gender'),
                      subtitle: Text(gender),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.05),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      onTap: () {
                        final options = ['Male', 'Female'];
                        String? selected;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Center(
                              child: AlertDialog(
                                title: const Text('Set your gender:'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: 100,
                                  child: StatefulBuilder(
                                    builder: (context, setState) {
                                      return ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: options.length,
                                        itemBuilder: (context, index) {
                                          return RadioListTile(
                                            visualDensity: VisualDensity.compact,
                                            title: Text(options[index]),
                                            groupValue: selected,
                                            value: options[index],
                                            onChanged: (value) {
                                              setState(() {
                                                selected = value;
                                              });
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Save'),
                                    onPressed: () {
                                      if (selected != null) {
                                        final document =
                                            FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
                                        document.set({'gender': selected}, SetOptions(merge: true)).then((value) {
                                          setState(() {
                                            gender = selected!;
                                          });
                                          Navigator.of(context, rootNavigator: true).pop();
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 5),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                      title: const Text('Skin tone'),
                      subtitle: Text(skinTone),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.05),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      onTap: () {
                        final options = ['Pale', 'Fair', 'Medium', 'Olive', 'Naturally brown', 'Dark brown'];
                        String? selected;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Center(
                              child: AlertDialog(
                                title: const Text('Set your skin tone:'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: 300,
                                  child: StatefulBuilder(
                                    builder: (context, setState) {
                                      return ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: options.length,
                                        itemBuilder: (context, index) {
                                          return RadioListTile(
                                            visualDensity: VisualDensity.compact,
                                            title: Text(options[index]),
                                            groupValue: selected,
                                            value: options[index],
                                            onChanged: (value) {
                                              setState(() {
                                                selected = value;
                                              });
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Save'),
                                    onPressed: () {
                                      if (selected != null) {
                                        final document =
                                            FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
                                        document.set({'skin_tone': selected}, SetOptions(merge: true)).then((value) {
                                          setState(() {
                                            skinTone = selected!;
                                          });
                                          Navigator.of(context, rootNavigator: true).pop();
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 5),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                      title: const Text('Skin type'),
                      subtitle: Text(skinType),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      tileColor: darken(Theme.of(context).colorScheme.surface, percentage: 0.05),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      onTap: () {
                        final options = ['Oily', 'Dry', 'Normal', 'Combination', 'Sensitive'];
                        String? selected;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Center(
                              child: AlertDialog(
                                title: const Text('Set your skin type:'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: 250,
                                  child: StatefulBuilder(
                                    builder: (context, setState) {
                                      return ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: options.length,
                                        itemBuilder: (context, index) {
                                          return RadioListTile(
                                            visualDensity: VisualDensity.compact,
                                            title: Text(options[index]),
                                            groupValue: selected,
                                            value: options[index],
                                            onChanged: (value) {
                                              setState(() {
                                                selected = value;
                                              });
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Save'),
                                    onPressed: () {
                                      if (selected != null) {
                                        final document =
                                        FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
                                        document.set({'skin_type': selected}, SetOptions(merge: true)).then((value) {
                                          setState(() {
                                            skinType = selected!;
                                          });
                                          Navigator.of(context, rootNavigator: true).pop();
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
