import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/src/widgets/gallery_page.dart';

class ScanPage extends StatefulWidget {
  final CameraDescription camera;
  const ScanPage({super.key, required this.camera});
  @override
  ScanPageState createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> {
  var classification = 'Unknown';
  late CameraController controller;
  late Future<void> initializeControllerFuture;
  final channel = const MethodChannel('app.android/channel');

  Future<void> scanPhoto() async {
    try {
      await initializeControllerFuture;
      final image = await controller.takePicture();
      final result =
      await channel.invokeMethod<String>('scanPhoto', image.path);
      setState(() {
        classification = '$result';
      });
    } on PlatformException catch (exception) {
      print(exception.message);
    }
  }

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.medium);
    initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        FutureBuilder<void>(
          future: initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(controller);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        ElevatedButton(
          child: const Text('Open an existing image'),
          onPressed: () async {
            String? selectedImagePath = await Navigator.push<String?>(context,
                MaterialPageRoute(builder: (context) => const GalleryPage()));
            try {
              final result = await channel.invokeMethod<String>(
                  'scanPhoto', selectedImagePath);
              setState(() {
                classification = '$result';
              });
            } on PlatformException catch (exception) {
              print(exception.message);
            }
          },
        ),
        Text(classification),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: scanPhoto,
        child: const Icon(Icons.camera),
      ),
    );
  }
}