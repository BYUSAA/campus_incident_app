// File generated from android/app/google-services.json for Firebase project
// 'inzira-498621'. Equivalent to `flutterfire configure --platforms=android`.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for Android.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4dWCuiakJ-hGCk_UJ2OqrlvyJoYsRQOo',
    appId: '1:1032480882805:android:bb2a1ac4cff6371633b83c',
    messagingSenderId: '1032480882805',
    projectId: 'inzira-498621',
    storageBucket: 'inzira-498621.firebasestorage.app',
  );
}
