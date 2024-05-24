import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/src/widgets/result_page.dart';
import 'package:app/src/widgets/gallery_page.dart';
import 'package:app/src/components/dialog_components.dart';
import 'package:app/src/utils/color_utils.dart';
import 'package:image/image.dart' as image_utils;
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

const double confidenceThreshold = 0.85;

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

  Future<(int, double)> scanImage(String imagePath) async {
    final result = await channel.invokeMethod('scanImage', imagePath);
    final labelId = result['label_id'] as int;
    final confidence = result['confidence'] as double;
    return (labelId, confidence);
  }

  Future<void> uploadHistory(int labelId, double confidence, String imagePath) async {
    if (FirebaseAuth.instance.currentUser != null) {
      final date = DateTime.now();
      final reference = FirebaseStorage.instance.ref('users/${FirebaseAuth.instance.currentUser!.uid}/$date.png');
      await reference.putFile(File(imagePath));
      FirebaseFirestore.instance.collection('history').add({
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'image_url': await reference.getDownloadURL(),
        'label_id': labelId,
        'confidence': confidence,
        'date': date
      });
    }
  }

  Future<void> open() async {
    try {
      final imagePath =
          await Navigator.push<String?>(context, MaterialPageRoute(builder: (context) => const GalleryPage()));
      if (imagePath != null) {
        showProgressionDialog(context: context);
        final (labelId, confidence) = await scanImage(imagePath);
        Navigator.of(context, rootNavigator: true).pop();
        if (confidence > confidenceThreshold) {
          uploadHistory(labelId, confidence, imagePath);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ResultPage(labelId: labelId, confidence: confidence, imagePath: imagePath)));
        } else {
          showMessageDialog(context: context, message: "The scan wasn't able to detect any of the supported diseases.");
        }
      }
    } on Exception {
      Navigator.of(context, rootNavigator: true).pop();
      showMessageDialog(context: context, message: 'Sorry, something went wrong.');
    }
  }

  Future<void> scan() async {
    try {
      showProgressionDialog(context: context);
      await initializeControllerFuture;
      await controller.setFlashMode(FlashMode.off);
      final image = await controller.takePicture();
      final imagePath = image.path;
      final imageFile = File(imagePath);
      image_utils.Image? decodedImage = image_utils.decodeImage(await imageFile.readAsBytes());
      int cropSize = (decodedImage!.width * 0.70).round();
      cropSize = cropSize < 224 ? 224 : cropSize;
      int startX = ((decodedImage.width - cropSize) / 2).round();
      int startY = ((decodedImage.height - cropSize) / 2).round();
      image_utils.Image croppedImage =
          image_utils.copyCrop(decodedImage, x: startX, y: startY, width: cropSize, height: cropSize);
      imageFile.writeAsBytesSync(image_utils.encodePng(croppedImage));
      final (labelId, confidence) = await scanImage(imagePath);
      Navigator.of(context, rootNavigator: true).pop();
      if (confidence > confidenceThreshold) {
        uploadHistory(labelId, confidence, imagePath);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ResultPage(labelId: labelId, confidence: confidence, imagePath: imagePath)));
      } else {
        showMessageDialog(context: context, message: "The scan wasn't able to detect any of the supported diseases.");
      }
    } on Exception {
      Navigator.of(context, rootNavigator: true).pop();
      showMessageDialog(context: context, message: 'Sorry, something went wrong.');
    }
  }

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.max);
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
                if (controller.value.isInitialized) {
                  return LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxWidth / controller.value.aspectRatio,
                        child: CameraPreview(controller,
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
                            )),
                      );
                    },
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        size: 25,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 5),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 35),
                        child: Text('Camera permission not granted'),
                      )
                    ],
                  );
                }
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
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Important notice:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22)),
                      SizedBox(height: 5),
                      Text(
                          'For optimal results, please ensure that the image is taken in a well-lit area and is not blurry. The affected skin area should be within the highlighted area in the image.',
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(overlayColor: MaterialStateProperty.resolveWith((states) {
                          return darken(Theme.of(context).colorScheme.primary);
                        }), backgroundColor: MaterialStateProperty.resolveWith((states) {
                          return Theme.of(context).colorScheme.primary;
                        }), elevation: MaterialStateProperty.resolveWith((states) {
                          return 5;
                        })),
                        onPressed: open,
                        child: const Text('Open',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      const SizedBox(width: 25),
                      ElevatedButton(
                          style: ButtonStyle(overlayColor: MaterialStateProperty.resolveWith((states) {
                            return darken(Theme.of(context).colorScheme.primary);
                          }), backgroundColor: MaterialStateProperty.resolveWith((states) {
                            return Theme.of(context).colorScheme.primary;
                          }), elevation: MaterialStateProperty.resolveWith((states) {
                            return 5;
                          })),
                          onPressed: scan,
                          child: const Text('Scan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              )))
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
