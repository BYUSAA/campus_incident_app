# Device integration tests

Integration tests exercise the app in a running Flutter environment. They can initialize Firebase and require a configured Android device or emulator.

## Prerequisites

- Android runner files generated with `flutter create --platforms=android .`.
- Firebase options generated with `flutterfire configure --platforms=android`.
- Firebase Authentication and other required Firebase products enabled.
- Android emulator or physical device visible to `flutter devices`.

## Run

From the repository root:

```powershell
flutter pub get
flutter devices
flutter test integration_test/app_workflow_test.dart
```

The current smoke test initializes Firebase and checks the signed-out navigation path. It is not yet a complete end-to-end test of registration, photo upload, student ownership, and staff moderation.

## Test data safety

Use dedicated test accounts and records. Do not use classmates' accounts or real incident information. Clean up test reports and uploaded images where appropriate. Never store passwords, tokens, Firebase service-account files, or private keys in the test source.

Expand the integration suite as the real Firebase workflow becomes available and record actual outcomes in `docs/technical_report.md`.
