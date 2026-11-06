# Unit and widget tests

This folder contains automated checks that can run without contacting the live Firebase project.

## Run the suite

From the repository root:

```powershell
flutter pub get
flutter test
```

Run individual files:

```powershell
flutter test test/models/incident_test.dart
flutter test test/providers/incident_provider_test.dart
flutter test test/widgets/incident_card_test.dart
```

## Current coverage

| Test | Coverage |
| --- | --- |
| `models/incident_test.dart` | Firestore mapping, safe defaults, timestamp conversion, and legacy image URL compatibility |
| `core/validators_test.dart` | ALU email validation, required fields, and password length |
| `providers/incident_provider_test.dart` | Student and staff incident stream handling with a fake repository |
| `widgets/incident_card_test.dart` | Incident card title and status rendering |
| `services/incident_repository_test.dart` | Model payload shape used when saving an incident |

The repository test checks the serialized Firestore payload. It is not a full mocked Firebase repository test.

## Device integration smoke test

The current device-level smoke test is at `integration_test/app_workflow_test.dart`. It requires generated Firebase options and a configured Android device or emulator:

```powershell
flutter test integration_test/app_workflow_test.dart
```

It initializes Firebase and checks the signed-out navigation path. It is not yet an end-to-end test of registration, photo upload, student ownership, and staff moderation.

## Recommended next tests

- Firestore Emulator rules tests for student ownership and staff access.
- Storage Emulator tests for UID path restrictions, image MIME types, and the 8 MB limit.
- Auth tests for verified/unverified and missing-profile accounts.
- Widget tests for incident form validation, photo picker, and status updates.
- Full student-to-staff workflow tests using dedicated Firebase test accounts.

Record real command output and the Flutter/Dart version used. Do not mark a test as passing until it has run successfully.
