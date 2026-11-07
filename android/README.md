# Android platform setup

Android is the primary development, test, and assignment-demonstration target.

## Current repository state

The repository contains setup guidance rather than generated Android Gradle, manifest, and Kotlin runner files. Generate the native runner using Flutter on the Windows development computer.

## Generate the Android runner

From the repository root in PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tooling\bootstrap-android.ps1
```

The script:
- Checks Flutter and displays `flutter doctor -v`.
- Generates Android runner files only if the runner is missing.
- Uses organization prefix `com.byusa`.
- Installs Flutter dependencies.
- Prints the generated Android application ID.

For the current package name, the expected application ID is `com.byusa.campus_incident_reporter`. The Android minimum SDK is set to API 24 for Firebase Android SDK 35 compatibility. Confirm the actual value in `android/app/build.gradle.kts` and register that exact ID in Firebase Console.

Direct commands:

```powershell
flutter doctor -v
flutter create --platforms=android --org com.byusa .
flutter pub get
```

Review generated platform files before committing them. Preserve local SDK paths and signing configuration outside source control.

## Configure Firebase

Enable Email/Password Authentication, Cloud Firestore, and Cloud Storage. Then run:

```powershell
.\tooling\bootstrap-firebase.ps1 -ProjectId YOUR_FIREBASE_PROJECT_ID
```

This generates `lib/firebase_options.dart` for Android and asks before deploying Firestore rules/indexes and Storage rules. See [Firebase setup](../firebase/README.md).

## Run and build

```powershell
flutter devices
flutter run
flutter build apk --debug
```

Test gallery selection and camera capture on the actual Android target. Use an emulator image with Google Play services for Firebase-related device testing.

## Security and evidence

- Never commit keystore files, signing passwords, private signing keys, service account JSON, or local SDK paths.
- Confirm the application ID and Firebase project before deploying.
- Use dedicated test accounts and obscure personal information in evidence.
- Record actual build/test results in the technical report.

The GitHub Actions workflow generates a temporary Android runner in CI and builds a debug APK artifact. The developer's local runner still needs to be generated for the device demonstration.