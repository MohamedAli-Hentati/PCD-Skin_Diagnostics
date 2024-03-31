import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/src/widgets/result_page.dart';
import 'package:app/src/widgets/gallery_page.dart';
import 'package:app/src/components/dialog_components.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ScanPage extends StatefulWidget {
  final CameraDescription camera;
  const ScanPage({super.key, required this.camera});
  @override
  ScanPageState createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> {
  final channel = const MethodChannel('app.android/channel');
  late Future<void> initializeControllerFuture;
  late CameraController controller;

  Future<String?> scanImage(String imagePath) async {
    try {
      final result = channel.invokeMethod<String>('scanImage', imagePath);
      if (FirebaseAuth.instance.currentUser != null) {
        final date = DateTime.now();
        final reference = FirebaseStorage.instance.ref('users/${FirebaseAuth.instance.currentUser!.uid}/$date.png');
        await reference .putFile(File(imagePath));
        FirebaseFirestore.instance.collection('history').add({
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'image_url': await reference.getDownloadURL(),
          'result': await result,
          'date': date
        });
      }
      return result;
    } on Exception {
      return null;
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
        Expanded(
          flex: 7,
          child: FutureBuilder<void>(
            future: initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(
                  controller,
                  child: Center(
                    child: CustomPaint(
                      foregroundPainter: BorderPainter(),
                      child: Container(
                        width: 224,
                        height: 224,
                        color: Colors.transparent,
                        child: const Center(
                            child: SizedBox(
                          width: 125,
                          child: Text(
                            textAlign: TextAlign.center,
                            'Position affected skin area here',
                            style: TextStyle(fontSize: 17, color: Colors.white54),
                          ),
                        )),
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        const Divider(
          height: 0,
          thickness: 2.5,
          color: Colors.white54,
        ),
        Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
              child: Column(
                children: [
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Important notice:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22)),
                      Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ac semper nunc. Mauris est justo, aliquet et ultrices eu, vulputate vel urna. Cras scelerisque semper felis eget mollis.',
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () async {
                            try {
                              final imagePath = await Navigator.push<String?>(
                                  context, MaterialPageRoute(builder: (context) => const GalleryPage()));
                              if (imagePath != null) {
                                showProgressionDialog(context: context);
                                final result = await scanImage(imagePath);
                                Navigator.of(context, rootNavigator: true).pop();
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResultPage(result: result!)));
                              }
                            } on Exception {
                              Navigator.of(context, rootNavigator: true).pop();
                              showMessageDialog(context: context, message: 'Sorry, something went wrong.');
                            }
                          },
                          child: const Text('Open')),
                      TextButton(
                          onPressed: () async {
                            try {
                              showProgressionDialog(context: context);
                              await initializeControllerFuture;
                              final image = await controller.takePicture();
                              final result = await scanImage(image.path);
                              Navigator.of(context, rootNavigator: true).pop();
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResultPage(result: result!)));
                            } on Exception {
                              Navigator.of(context, rootNavigator: true).pop();
                              showMessageDialog(context: context, message: 'Sorry, something went wrong.');
                            }
                          },
                          child: const Text('Scan'))
                    ],
                  )
                ],
              ),
            ))
      ]),
    );
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double sh = size.height;
    double sw = size.width;
    double cornerSide = sh * 0.1;

    Paint paint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    Path path = Path()
      ..moveTo(cornerSide, 0)
      ..quadraticBezierTo(0, 0, 0, cornerSide)
      ..moveTo(0, sh - cornerSide)
      ..quadraticBezierTo(0, sh, cornerSide, sh)
      ..moveTo(sw - cornerSide, sh)
      ..quadraticBezierTo(sw, sh, sw, sh - cornerSide)
      ..moveTo(sw, cornerSide)
      ..quadraticBezierTo(sw, 0, sw - cornerSide, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;
}
