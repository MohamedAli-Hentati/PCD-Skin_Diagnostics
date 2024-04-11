import 'package:flutter/material.dart';
import 'package:app/src/project_theme.dart' as colors;
import 'package:app/src/components/text_place.dart';
import 'package:app/src/components/bottom_navigation.dart';
import 'package:app/src/widgets/plans_page.dart';
import 'package:app/src/widgets/warning_page.dart';

class Objectives extends StatefulWidget {
  const Objectives({super.key});

  @override
  State<Objectives> createState() => _ObjectivesState();
}

class _ObjectivesState extends State<Objectives> {
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
          Padding(padding: EdgeInsets.only(left: 10),
            child:Text(style:theme.textTheme.titleSmall?.copyWith(color: const Color(colors.mainColor)),'inspiration'),
            
          ),
          TextPlace(
              text: 'Skin deseases are becoming more rampant these days.',
              description: 'Description'),
          TextPlace(
              text:
                  'Emergency situations without the ability to seek proffessional.  ',
              description: 'Description'),
          TextPlace(
              text: 'Unability to afford treatment',
              description: 'Description'),
          Padding(padding: EdgeInsets.only(left: 10,top:10),
            child:Text(style: theme.textTheme.titleSmall?.copyWith(color: const Color(colors.mainColor)),'objectives'),
            
          ),
          TextPlace(
              text:
                  'Integrating AI technologies specifically deep learning to help diagnose skin anomalies',
              description: 'Description'),
          TextPlace(
              text:
                  'Asses the feasability of such an application using a smaller sample of pathologies.',
              description: 'Description'),
          TextPlace(
              text:
                  'Help by describing suitable in a natural auto-generated manner.',
              description: 'Description'),
          TextPlace(
              text:
                  'Provide an app that will be a foundation for online healthcare in tunisia.',
              description: 'Description'),
          TextPlace(
              text:
                  'Make the app easily extensible for future upgrades and new features.',
              description: 'Description'),
        BottomNavigation(leftPage:Plans(), rightPage:Warning() , pageName: 'Objectives',backgroundcolor: Colors.white,)
        ],
      ),
    );
  }
}
