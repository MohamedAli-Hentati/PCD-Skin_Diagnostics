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
                        child: Center(
                            child: Text(
                          classification,
                          style: TextStyle(fontSize: 15, color: Colors.white70),
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
        Divider(
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LOREM IPSUM DOLOR', style: TextStyle(fontSize: 20)),
                      Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ac semper nunc. Mauris est justo, aliquet et ultrices eu, vulputate vel urna. Cras scelerisque semper felis eget mollis.',
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () async {
                            String? selectedImagePath =
                                await Navigator.push<String?>(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const GalleryPage()));
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
                          child: Text('Open')),
                      TextButton(
                          onPressed: () async {
                            scanPhoto();
                          },
                          child: Text('Scan'))
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
    double sh = size.height; // for convenient shortage
    double sw = size.width; // for convenient shortage
    double cornerSide = sh * 0.1; // desirable value for corners side

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
