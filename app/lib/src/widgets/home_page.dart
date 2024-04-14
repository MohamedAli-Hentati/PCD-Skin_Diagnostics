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
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 50,
          crossAxisSpacing: 50,
          crossAxisCount: 2,
          children: const [
            ClickBox(page: Objectives(), icon: Icons.list_alt_outlined, text: 'Objective'),
            ClickBox(page: Utility(), icon: Icons.help_outline, text: 'FAQ'),
            ClickBox(page: Plans(), icon: Icons.map_outlined, text: 'Roadmap'),
            ClickBox(page: Warning(), icon: Icons.warning_amber_rounded, text: 'Warning')
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
