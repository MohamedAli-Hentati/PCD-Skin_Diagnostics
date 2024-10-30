import 'package:flutter/material.dart';

class TextPlace extends StatefulWidget {
  final String text, description;
  static int id = 0;
  const TextPlace({super.key, required this.text, required this.description});

  @override
  State<TextPlace> createState() => _TextPlaceState();
}

class _TextPlaceState extends State<TextPlace> {
  double heights = 0;
  Icon icon = Icon(Icons.add);
  void grow() {
    setState(() {
      heights = 100;
      icon = Icon(Icons.remove);
    });
  }

  void shrink() {
    setState(() {
      heights = 0;
      icon = Icon(Icons.add);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextPlace.id++;
    return Padding(
      padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 5.0),
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey.shade600, blurRadius: 7.0, blurStyle: BlurStyle.outer)],
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(5.0)),
        height: 80 + heights,
        width: 200,
        child: Column(textBaseline: TextBaseline.alphabetic, crossAxisAlignment: CrossAxisAlignment.baseline, children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                    padding: EdgeInsets.only(top: 3.0, left: 3.0),
                    child: Text(
                      widget.text,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    )),
                flex: 1,
              ),
              Padding(
                padding: EdgeInsets.only(right: 5, top: 10),
                child: FloatingActionButton(
                    heroTag: TextPlace.id,
                    child: icon,
                    shape: CircleBorder(),
                    backgroundColor: Colors.grey.shade300,
                    onPressed: () {
                      if (heights == 0) {
                        grow();
                      } else {
                        shrink();
                      }
                    }),
              )
            ],
          ),
          Container(
            height: heights,
            child: Padding(
                padding: EdgeInsets.only(left: 3.0),
                child: Text(
                  widget.description,
                )),
          )
        ]),
      ),
    );
  }
}
