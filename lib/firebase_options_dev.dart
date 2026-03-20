// GENERATED — replace with actual Firebase options from FlutterFire CLI
// Run: flutterfire configure --project=nucleus-dev
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform for Firebase');
    }
  }

  // TODO: Replace with real values from FlutterFire CLI
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_DEV_ANDROID_API_KEY',
    appId: '1:111111111111:android:1111111111111111111111',
    messagingSenderId: '111111111111',
    projectId: 'nucleus-dev',
    storageBucket: 'nucleus-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_DEV_IOS_API_KEY',
    appId: '1:111111111111:ios:1111111111111111111111',
    messagingSenderId: '111111111111',
    projectId: 'nucleus-dev',
    storageBucket: 'nucleus-dev.appspot.com',
    iosBundleId: 'app.nucleus.dev',
  );
}
