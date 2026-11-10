# Local setup scripts

The scripts in this folder automate the repeatable parts of the Windows setup. The repository's `.firebaserc` selects the user-provided INZIRA project (`inzira-498621`); no API keys, private credentials, or service-account files are stored here.

## 1. Generate the Android platform

Run from the repository root in PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tooling\bootstrap-android.ps1
```

The script creates the Android runner with organization prefix `com.byusa`, installs Flutter dependencies, and prints the generated application ID. With the current Flutter project name, the expected ID is `com.byusa.campus_incident_reporter`. Confirm the actual value in `android/app/build.gradle.kts` before registering it in Firebase Console.

The script does not overwrite an existing Android runner.

## 2. Configure the Firebase project

Use the project ID shown in your Firebase Console:

```powershell
.\tooling\bootstrap-firebase.ps1
```

The script defaults to INZIRA (`inzira-498621`), installs/checks the Firebase CLI and FlutterFire CLI, runs `flutterfire configure --project inzira-498621 --platforms=android`, and verifies that the generated options file replaced the repository placeholder. Pass `-ProjectId another-project-id` only when intentionally targeting a different project. It asks for an explicit `YES` before deploying Firestore rules, indexes, or Storage rules.

Before accepting deployment, confirm in Firebase Console that Email/Password Authentication, Cloud Firestore, and Cloud Storage are enabled and that this is the correct project.

## 3. Verify the mobile app

```powershell
flutter pub get
dart format lib test integration_test
flutter analyze
flutter test
flutter build apk --debug
flutter devices
flutter run
```

Run the student workflow and a separate administrator-assigned staff workflow on an Android emulator or physical device. Record real outcomes in the technical report.

## Safety

- Never add Firebase Admin SDK service-account JSON, private keys, passwords, or signing files to Git.
- The FlutterFire options file contains client configuration identifiers, not Admin SDK credentials.
- The scripts do not create test users, change roles, fabricate screenshots, or produce a demonstration video.
