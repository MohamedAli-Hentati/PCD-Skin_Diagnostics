import 'package:flutter/material.dart';
import 'package:app/src/widgets/objectives_page.dart';
import 'package:app/src/components/click_box.dart';
import 'package:app/src/widgets/plans_page.dart';
import 'package:app/src/widgets/warning_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Color(0xFF03045E), fontWeight: FontWeight.w600)),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey.shade100),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: const [
            Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(bottom: 15.0),
                          child: ClickBox(page: Objectives(), icon: Icons.person_search, text: 'Objective')),
                      ClickBox(
                        page: Utility(),
                        icon: Icons.handyman,
                        text: 'Utility',
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 15.0),
                        child: ClickBox(page: Plans(), icon: Icons.map, text: 'Plans'),
                      ),
                      ClickBox(page: Warning(), icon: Icons.warning, text: 'Warning'),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Utility extends StatelessWidget {
  const Utility({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
