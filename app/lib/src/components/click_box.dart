import 'package:flutter/material.dart';
import 'package:app/src/project_theme.dart' as colors;

class ClickBox extends StatelessWidget {
  final Widget page;
  final IconData icon;
  final String text;
  const ClickBox({super.key, required this.page, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade600, blurRadius: 2.5, blurStyle: BlurStyle.outer)
            ],
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.elliptical(7.0, 5.0)),
            border: Border(
                bottom: BorderSide(
              color: theme.colorScheme.primary,
              width: 5,
            ))),
        width: 120,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(style: theme.textTheme.titleSmall, text),
            Icon(
              icon,
              size: 35,
            ),
            const SizedBox(height: 0)
          ],
        ),
      ),
    );
  }
}
