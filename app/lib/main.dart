import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

late MethodChannel channel;
late CameraDescription firstCamera;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var cameras = await availableCameras();
  channel = const MethodChannel('channel');
  firstCamera = cameras.first;
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin diagnostics application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Navigation(),
    );
  }
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => NavigationState();
}
class NavigationState extends State<Navigation> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.question_mark),
            label: 'Detect',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[const HomeScreen(title: 'Hello'), const TakePictureScreen(), const GalleryScreen()][currentPageIndex],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;
  @override
  State<HomeScreen> createState() => HomeScreenState();
}
class HomeScreenState extends State<HomeScreen> {
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
  const TakePictureScreen({super.key});
  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}
class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController controller;
  late Future<void> initializeControllerFuture;
  String classification = 'Unknown';
  Future<void> classifyImage() async {
    try {
      await initializeControllerFuture;
      final image = await controller.takePicture();
      final result = await channel.invokeMethod<String>('classifyImage', image.path);
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
    controller = CameraController(firstCamera, ResolutionPreset.medium);
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
      appBar: AppBar(title: const Text('Take a picture')),
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
            String? selectedImagePath = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const GalleryScreen()));
            try {
              final result = await channel.invokeMethod<String>('classifyImage', selectedImagePath);
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
        onPressed: classifyImage,
        child: const Icon(Icons.camera),
      ),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  GalleryScreenState createState() => GalleryScreenState();
}
class GalleryScreenState extends State<GalleryScreen> {
  File? selectedImage;

  Future<void> pickImage() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
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