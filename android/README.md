# Android platform setup

Android is the primary target for development, functional testing, and the final mobile demonstration.

## Repository state

This folder currently contains setup guidance rather than generated Android Gradle, manifest, and Kotlin runner files. Generate native files with the Flutter SDK installed on the developer's computer.

## Generate the Android project

From the repository root:

```powershell
flutter doctor
flutter create --platforms=android .
```

Review the Git diff after generation. Confirm the Android application ID in the generated Gradle configuration; use that exact ID when registering the Android app in Firebase Console.

## Firebase setup

1. Register the generated Android application ID in the Firebase project.
2. Enable Email/Password Authentication, Cloud Firestore, and Firebase Storage.
3. From the project root, run:

   ```powershell
   flutterfire configure --platforms=android
   ```

4. Confirm that the command generated `lib/firebase_options.dart`.
5. Deploy the repository Firestore and Storage rules/indexes.

## Run on Android

```powershell
flutter pub get
flutter devices
flutter run
```

Build a debug APK:

```powershell
flutter build apk --debug
```

Test both gallery selection and camera capture on the actual Android target. Emulator camera behavior depends on the selected virtual device.

## Android security notes

- Never commit keystore files, signing passwords, private signing keys, service account JSON, or local SDK paths.
- Confirm the application ID and Firebase project before preparing a release build.
- Demonstrate the app against the Firebase project documented in the report.
- Obscure emails, UIDs, credentials, and other private information in screenshots/video.
