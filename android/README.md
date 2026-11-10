# Android platform

Android is the primary runtime target for Campus Incident Reporter and the required assignment demonstration platform.

## Generated Android runner

The native Flutter Android project is committed in this directory. It includes the application module, Android manifest, Kotlin MainActivity, Gradle project settings, and Gradle wrapper distribution configuration. Flutter's own Android tooling injects the wrapper launch scripts when a Flutter build is invoked.

- Android application ID: `com.byusa.campus_incident_reporter`
- Kotlin namespace: `com.byusa.campus_incident_reporter`
- Minimum Android SDK: API 24
- Entry point: `app/src/main/kotlin/com/byusa/campus_incident_reporter/MainActivity.kt`

## Run on Android

From the repository root in PowerShell:

```powershell
flutter pub get
flutter devices
flutter run
```

Build a debug APK:

```powershell
flutter build apk --debug
```

## Firebase

Register the exact application ID above in the Firebase project. Enable Email/Password Authentication, Cloud Firestore, and Cloud Storage, then generate the project-specific Android options:

```powershell
.\tooling\bootstrap-firebase.ps1
```

The generated `lib/firebase_options.dart` is specific to your Firebase project. It is intentionally not fabricated in source control. See [Firebase setup](../firebase/README.md).

## Security

Do not commit `local.properties`, `key.properties`, signing keystores, service-account JSON, or private credentials. These are excluded by the root `.gitignore`.
