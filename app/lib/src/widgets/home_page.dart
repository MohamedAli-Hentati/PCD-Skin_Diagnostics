import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static const platform = MethodChannel('channel');
  String _pytorchVersion = 'Unknown version number';

  Future<void> _getPytorchVersion() async {
    String pytorchVersion;
    try {
      final result = await platform.invokeMethod<String>('getPytorchVersion');
      pytorchVersion = '$result';
    } on PlatformException catch (exception) {
      pytorchVersion = '${exception.message}';
    }

    setState(() {
      _pytorchVersion = pytorchVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: Center(child: Text('Home page')));
  }
}
