// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDlRKfCYbGxyoA25sopK5QX9xyEtysPu8s',
    appId: '1:477439941618:web:4562ccd61e37936750e96b',
    messagingSenderId: '477439941618',
    projectId: 'flutter1-7cb03',
    authDomain: 'flutter1-7cb03.firebaseapp.com',
    storageBucket: 'flutter1-7cb03.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBCIBNDKyyBydoSOjlB5FYmRAhNu2wPUQ8',
    appId: '1:477439941618:android:8fbfad7cb105640250e96b',
    messagingSenderId: '477439941618',
    projectId: 'flutter1-7cb03',
    storageBucket: 'flutter1-7cb03.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAN9ZRZ6syCXzV-2T4TglKHfyUeQuLFId8',
    appId: '1:477439941618:ios:596e62b5048e2fa450e96b',
    messagingSenderId: '477439941618',
    projectId: 'flutter1-7cb03',
    storageBucket: 'flutter1-7cb03.firebasestorage.app',
    androidClientId: '477439941618-24lgjrv7odq84641f03knprf4kolqgas.apps.googleusercontent.com',
    iosClientId: '477439941618-24ipo4vc11stbdq1lav1jm04qskar41r.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutter10',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAN9ZRZ6syCXzV-2T4TglKHfyUeQuLFId8',
    appId: '1:477439941618:ios:596e62b5048e2fa450e96b',
    messagingSenderId: '477439941618',
    projectId: 'flutter1-7cb03',
    storageBucket: 'flutter1-7cb03.firebasestorage.app',
    androidClientId: '477439941618-24lgjrv7odq84641f03knprf4kolqgas.apps.googleusercontent.com',
    iosClientId: '477439941618-24ipo4vc11stbdq1lav1jm04qskar41r.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutter10',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDlRKfCYbGxyoA25sopK5QX9xyEtysPu8s',
    appId: '1:477439941618:web:eef7b8bf7181155f50e96b',
    messagingSenderId: '477439941618',
    projectId: 'flutter1-7cb03',
    authDomain: 'flutter1-7cb03.firebaseapp.com',
    storageBucket: 'flutter1-7cb03.firebasestorage.app',
  );
}
