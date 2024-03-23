// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCSE22D8Z_Ne0J7hQtktdLHxqL0nzeA420',
    appId: '1:792812960447:web:84edc2c55de3aa3c24a40a',
    messagingSenderId: '792812960447',
    projectId: 'skin-diagnostics-application',
    authDomain: 'skin-diagnostics-application.firebaseapp.com',
    storageBucket: 'skin-diagnostics-application.appspot.com',
    measurementId: 'G-EZFGRBLF1G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD9w67dUASXbdRzHGahtjBsHDXIeMtzOy0',
    appId: '1:792812960447:android:519ed9b4278b696824a40a',
    messagingSenderId: '792812960447',
    projectId: 'skin-diagnostics-application',
    storageBucket: 'skin-diagnostics-application.appspot.com',
  );
}
