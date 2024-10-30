import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  final Color backgroundcolor;
  final Widget leftPage, rightPage;
  final String pageName;
  const BottomNavigation({super.key, required this.leftPage, required this.rightPage, required this.pageName, required this.backgroundcolor});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            elevation: 0.0,
            backgroundColor: widget.backgroundcolor,
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => widget.leftPage));
            },
            child: Icon(Icons.keyboard_double_arrow_left),
            heroTag: '454847',
          ),
          Text(
            widget.pageName,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          FloatingActionButton(
            elevation: 0.0,
            backgroundColor: widget.backgroundcolor,
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => widget.rightPage));
            },
            child: Icon(Icons.keyboard_double_arrow_right),
            heroTag: '659847',
          )
        ],
      ),
    );
  }
}
