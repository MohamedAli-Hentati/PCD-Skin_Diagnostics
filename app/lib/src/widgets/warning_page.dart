import 'package:flutter/material.dart';
import 'package:app/src/components/bottom_navigation.dart';
import 'package:app/src/widgets/objectives_page.dart';
import 'package:app/src/widgets/plans_page.dart';

class Warning extends StatelessWidget {
  const Warning({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warning'),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.warning_rounded,
            size: 150,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 35),
            child: Text("• The results obtained upon the use of this application shouldn't be taken for granted.\n• Any diagnosis made by this app should be later checked by a professional.\n• By using this application you consent that any harm caused by using this app is and only the user's responsibility.",
                style: TextStyle(fontSize: 20)),
          ),
          BottomNavigation(
            leftPage: Objectives(),
            rightPage: Plans(),
            pageName: 'plans',
            backgroundcolor: Colors.white,
          )
        ],
      ),
    );
  }
}
