import 'package:flutter/material.dart';
import 'package:app/src/project_theme.dart' as colors;
import 'package:app/src/components/text_place.dart';
import 'package:app/src/components/bottom_navigation.dart';

class Plans extends StatefulWidget {
  const Plans({super.key});

  @override
  State<Plans> createState() => _PlansState();
}

class _PlansState extends State<Plans> {
  double heights = 100;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    void grow() {
      setState(() {
        heights = 200;
      });
    }

    void shrink() {
      setState(() {
        heights = 100;
      });
    }

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(style: theme.textTheme.titleSmall?.copyWith(color: const Color(colors.mainColor)), 'plans'),
          ),
          TextPlace(text: 'Enlarging the desease repertoire', description: 'Details'),
          TextPlace(text: 'Improving accuracy', description: 'Details'),
          TextPlace(text: 'Adding a space where patients have the ability to communiacte with doctors', description: 'Details'),
          Padding(
              padding: EdgeInsets.only(top: 440),
              child: BottomNavigation(
                leftPage: Plans(),
                rightPage: Plans(),
                pageName: 'plans',
                backgroundcolor: Colors.white,
              ))
        ],
      ),
    );
  }
}
