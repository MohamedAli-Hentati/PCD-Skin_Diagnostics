import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/src/widgets/scan_page.dart';
import 'package:app/src/widgets/home_page.dart';
import 'package:app/src/widgets/profile_wrapper_page.dart';
import 'package:camera/camera.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

late CameraDescription camera;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var cameras = await availableCameras();
  camera = cameras.firstWhere(
    (camera) => camera.lensDirection == CameraLensDirection.back,
  );
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skin diagnostics application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B4D8),
          primary: const Color(0xFF00B4D8),
          secondary: const Color(0xFF90E0EF),
          tertiary: const Color(0xFF0077B6),
          background: Colors.white,
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const SafeArea(top: false, child: Navigation()),
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
  Map<int, GlobalKey<NavigatorState>> navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
  };
  final pages = [const HomePage(), ScanPage(camera: camera), const ProfileWrapperPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Theme.of(context).primaryColor,
        selectedIndex: currentPageIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search_outlined),
            label: 'Scan',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle),
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
      body: Navigator(
        key: navigatorKeys[currentPageIndex],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (_) => pages.elementAt(currentPageIndex));
        },
      ),
    );
  }
}
