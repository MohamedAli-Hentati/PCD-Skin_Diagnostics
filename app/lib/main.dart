import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(Application(camera: firstCamera));
}

class Application extends StatelessWidget {
  final CameraDescription camera;
  const Application({super.key, required this.camera});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin diagnostics application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TakePictureScreen(camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'PyTorch Version: ',
            ),
            Text(
              _pytorchVersion,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getPytorchVersion,
        child: const Icon(Icons.adb),
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);
  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  static const platform = MethodChannel('channel');
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String _classification = 'Unknown';
  Future<void> classifyImage() async {
    String classification = 'Unknown';
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final result = await platform.invokeMethod<String>('classifyImage', image.path);
      classification = '$result';
    } on PlatformException catch (exception) {
      print(exception.message);
    }
    setState(() {
      _classification = classification;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      body: Column(children: [
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        ElevatedButton(
          child: Text('Open an existing image'),
          onPressed: ()
          async {
            String? selectedImagePath = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => GalleryScreen()));
            String classification = 'Unknown';
            try {
              final result = await platform.invokeMethod<String>('classifyImage', selectedImagePath);
              classification = '$result';
            } on PlatformException catch (exception) {
              print(exception.message);
            }
            setState(() {
              _classification = classification;
            });
          },
        ),
        Text(_classification),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: classifyImage,
        child: Icon(Icons.camera),
      ),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, _selectedImage!.path);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(title: Text('Select an Image')),
          body: Center(
            child: _selectedImage != null
                ? Image.file(_selectedImage!)
                : Text('No image selected'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _pickImage,
            child: Icon(Icons.photo_library),
          ),
        ));
  }
}
