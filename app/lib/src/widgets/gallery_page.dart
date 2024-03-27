import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  GalleryPageState createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
  File? selectedImage;

  Future<void> pickImage() async {
    final pickedImage =
    await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, selectedImage?.path);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Select an Image')),
          body: Center(
            child: selectedImage != null
                ? Image.file(selectedImage!)
                : const Text('No image selected'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: pickImage,
            child: const Icon(Icons.photo_library),
          ),
        ));
  }
}