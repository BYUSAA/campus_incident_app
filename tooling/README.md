# Local setup scripts

The scripts in this folder automate the repeatable Android, Firebase, and verification steps on Windows. They do not contain Firebase project IDs, API keys, credentials, or service-account files.

## Recommended: one-command preparation

From the repository root in PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tooling\prepare-android-firebase.ps1 -FirebaseProjectId YOUR_FIREBASE_PROJECT_ID
```

The preparation script:
- Checks Flutter, Dart, Node.js, and Java prerequisites.
- Generates the Android runner using the `com.byusa` organization prefix if it is missing.
- Checks Firebase CLI sign-in and opens the login flow if no account is authorized.
- Configures FlutterFire for the selected Firebase project and Android platform.
- Asks you to type `YES` before deploying Firestore rules/indexes and Storage rules.
- Installs Flutter dependencies, formats the Dart source, runs `flutter analyze`, and runs `flutter test --coverage`.
- Installs the Firebase Emulator test package and runs Firestore/Storage security-rule tests locally.
- Builds the Android debug APK and verifies that the APK exists.

The script stops on the first failing step and prints the command that needs attention. Emulator tests can be skipped only for a temporary setup-only run:

```powershell
.\tooling\prepare-android-firebase.ps1 -FirebaseProjectId YOUR_FIREBASE_PROJECT_ID -SkipEmulatorTests
```

Do not use the skip switch for final verification.

## Individual scripts

### Android only

```powershell
.\tooling\bootstrap-android.ps1
```

### Firebase configuration and optional deployment

```powershell
.\tooling\bootstrap-firebase.ps1 -ProjectId YOUR_FIREBASE_PROJECT_ID
```

The Firebase bootstrap uses explicit `--project` arguments so it does not depend on a local project alias. Review the deployment target before confirming.

## After preparation

Connect the Android emulator or phone, then run:

```powershell
flutter devices
flutter run
```

Run the Android integration smoke test on the device:

```powershell
flutter test integration_test/app_workflow_test.dart
```

## Safety

- Never add Firebase Admin SDK service-account JSON, private keys, passwords, or signing files to Git.
- FlutterFire options contain client configuration identifiers, not Admin SDK credentials.
- The scripts do not create fake test evidence, user accounts, or staff roles.