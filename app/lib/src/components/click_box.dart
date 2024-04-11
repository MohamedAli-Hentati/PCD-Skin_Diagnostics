import 'package:flutter/material.dart';
import 'package:app/src/project_theme.dart' as colors;

class ClickBox extends StatelessWidget {
  final Widget page;
  final IconData icon;
  final String text;
  const ClickBox({required this.page, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey.shade600, blurRadius: 5.0, blurStyle: BlurStyle.outer, offset: Offset(0, 0))],
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.elliptical(7.0, 5.0)),
            border: Border(
                bottom: BorderSide(
              color: Color(colors.secondaryColor),
              width: 7.0,
            ))),
        width: 180,
        height: 180,
        child: Column(
          children: [
            Padding(child: Text(style: theme.textTheme.titleSmall, text), padding: const EdgeInsets.only(top: 20)),
            Padding(
              child: Icon(
                icon,
                size: 60,
              ),
              padding: const EdgeInsets.only(top: 10),
            ),
          ],
        ),
      ),
    );
  }
}
