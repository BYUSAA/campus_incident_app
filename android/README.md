# Android platform

Android is the primary runtime target for Campus Incident Reporter and the required assignment demonstration platform.

## Generated Android runner

The native Flutter Android project is generated with Flutter 3.47.2 and committed in this directory. It includes the Gradle settings and wrapper, application module, Android manifest, and Kotlin MainActivity.

- Android application ID: `com.byusa.campus_incident_reporter`
- Kotlin namespace: `com.byusa.campus_incident_reporter`
- Minimum Android SDK: API 24
- Entry point: `app/src/main/kotlin/com/byusa/campus_incident_reporter/MainActivity.kt`

The repository workflow `.github/workflows/bootstrap-android.yml` can generate and commit the runner when this directory is missing the Android manifest. The workflow preserves this README.

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
.\tooling\bootstrap-firebase.ps1 -ProjectId YOUR_FIREBASE_PROJECT_ID
```

The generated `lib/firebase_options.dart` is specific to your Firebase project. It is intentionally not fabricated in source control. See [Firebase setup](../firebase/README.md).

## Security

Do not commit `local.properties`, `key.properties`, signing keystores, service-account JSON, or private credentials. These are excluded by the root `.gitignore`.
