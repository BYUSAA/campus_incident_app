# Device integration tests

Integration tests exercise the Flutter app in a live Android emulator or physical device. The current smoke test initializes Firebase and needs the actual project configuration.

## Prerequisites

- Android runner generated with `tooling/bootstrap-android.ps1`.
- Firebase options generated with `tooling/bootstrap-firebase.ps1`.
- Email/Password Authentication, Firestore, and Storage enabled.
- Android emulator or physical device visible to `flutter devices`.

## Run

```powershell
flutter pub get
flutter devices
flutter test integration_test/app_workflow_test.dart
```

The current test verifies the signed-out redirect to Login. It is narrower than the required full student/staff demo.

## Safe test data

Use dedicated test accounts and records. Do not use classmates' accounts or real incident information. Clean up test reports and uploaded photos when appropriate. Never store passwords, tokens, service-account JSON, or private keys in test source.

Record actual device details and test outcomes in `docs/technical_report.md`.