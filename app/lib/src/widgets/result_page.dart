import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String result;
  const ResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Result'),
            ),
            body: Center(child: Text('Result: $result'))));
  }
}
