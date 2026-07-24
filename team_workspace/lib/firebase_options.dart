// GENERATED PLACEHOLDER FILE.
//
// Run `flutterfire configure` from the project root to generate the real
// version of this file for your own Firebase project. It will overwrite
// this placeholder with the correct platform-specific options.
//
// See: https://firebase.google.com/docs/flutter/setup

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'run `flutterfire configure`.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform - '
          'run `flutterfire configure`.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCe6UiPdoNye3gZWDjm6-gl4nK3pRmgTtU',
    appId: '1:1019363345230:android:447ec78a17664b8068541f',
    messagingSenderId: '1019363345230',
    projectId: 'team-workspace-c0c5a',
    storageBucket: 'team-workspace-c0c5a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    storageBucket: '',
    iosBundleId: '',
  );
}
