import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  GalleryPageState createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
  String? selectedImagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Select an Image'), actions: [
          IconButton(
              padding: const EdgeInsets.only(right: 5),
              style: IconButton.styleFrom(shape: const RoundedRectangleBorder()),
              onPressed: () async {
                final selectedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (selectedImage != null) {
                  setState(() {
                    selectedImagePath = selectedImage.path;
                  });
                }
              },
              icon: const Icon(Icons.photo_library))
        ]),
        body: Center(
          child: selectedImagePath == null
              ? const Text('No image selected')
              : SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5625,
                  child: Stack(alignment: AlignmentDirectional.center, children: [
                    Image.file(
                      File(selectedImagePath!),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.5625,
                      fit: BoxFit.fill,
                    ),
                    Center(child: CustomPaint(
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
                                'Affected skin area here',
                                style: TextStyle(fontSize: 17, color: Colors.white54),
                              ),
                            )),
                      ),
                    )),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: 35,
                          height: 35,
                          child: IconButton(
                            padding: const EdgeInsets.all(0.0),
                            style: IconButton.styleFrom(
                                elevation: 5,
                                shadowColor: Colors.grey,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                            iconSize: 17.5,
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              Navigator.pop(context, selectedImagePath);
                            },
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
        ),
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
      ..color = Colors.white60
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
