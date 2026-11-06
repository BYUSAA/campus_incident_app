# Android platform setup

Android is the primary target for this assignment's mobile demonstration.

This directory currently contains setup instructions only. Generate native Gradle, manifest, and Kotlin scaffolding from the project root using the Flutter SDK installed on your computer:

```bash
flutter create --platforms=android .
```

Then:

1. Open the generated Android project in Android Studio if native configuration is needed.
2. Confirm the generated application ID and use that exact ID when registering the Android app in Firebase Console.
3. From the repository root, run `flutterfire configure --platforms=android` to generate the real `lib/firebase_options.dart`.
4. Run `flutter pub get` and `flutter run` with an Android emulator or physical device.

Do not commit local SDK paths, signing passwords, release keystores, or other private signing material. The project uses Firebase Authentication, Cloud Firestore, Firebase Storage, and image_picker.
