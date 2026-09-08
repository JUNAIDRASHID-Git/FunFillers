import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBpgfMxMKcXGfynLGuLsQf-8IbO3fsqNyk",
    authDomain: "funfillers-4541c.firebaseapp.com",
    projectId: "funfillers-4541c",
    storageBucket: "funfillers-4541c.firebasestorage.app",
    messagingSenderId: "961963945361",
    appId: "1:961963945361:web:1aad189b34e23b0c3dfe30",
    measurementId: "G-T58JK31L9X",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBpgfMxMKcXGfynLGuLsQf-8IbO3fsqNyk",
    appId: "1:961963945361:android:1aad189b34e23b0c3dfe30",
    messagingSenderId: "961963945361",
    projectId: "funfillers-4541c",
    storageBucket: "funfillers-4541c.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyBpgfMxMKcXGfynLGuLsQf-8IbO3fsqNyk",
    appId: "1:961963945361:ios:1aad189b34e23b0c3dfe30",
    messagingSenderId: "961963945361",
    projectId: "funfillers-4541c",
    storageBucket: "funfillers-4541c.firebasestorage.app",
    iosBundleId: "com.example.funfillers",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyBpgfMxMKcXGfynLGuLsQf-8IbO3fsqNyk",
    appId: "1:961963945361:ios:1aad189b34e23b0c3dfe30",
    messagingSenderId: "961963945361",
    projectId: "funfillers-4541c",
    storageBucket: "funfillers-4541c.firebasestorage.app",
    iosBundleId: "com.example.funfillers",
  );
}
