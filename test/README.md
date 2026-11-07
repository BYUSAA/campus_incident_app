# Flutter unit and widget tests

These tests run without a live Firebase project.

## Run the suite

```powershell
flutter pub get
flutter test
```

## Coverage map

| Test | Coverage |
| --- | --- |
| `core/validators_test.dart` | ALU email format/domain, profile name, password, and bounded report fields |
| `core/incident_status_test.dart` | Forward-only status progression |
| `models/incident_test.dart` | Firestore mapping, defaults, timestamp conversion, and image compatibility |
| `providers/incident_provider_test.dart` | Student/staff feeds, user switching, report submission, photo removal, status/delete delegation |
| `providers/theme_provider_test.dart` | System fallback, restoring saved appearance, and persisting a change |
| `widgets/photo_picker_test.dart` | Removing a previously uploaded photo |
| `widgets/incident_form_test.dart` | Required incident fields are validated before submit |
| `widgets/incident_card_test.dart` | Incident title and status rendering |

These validate client behavior. They do not replace backend Firebase security tests.

## Firebase Emulator Suite rules tests

The isolated rules tests live in `firebase/rules-tests/` and test Firestore and Storage authorization without a live Firebase project.

```powershell
cd firebase/rules-tests
npm install
cd ../..
firebase emulators:exec --project demo-campus-incident-reporter --only firestore,storage "npm --prefix firebase/rules-tests test"
```

The suite checks student ownership, profile privacy/protected fields, role self-promotion, verification, report lifecycle, student and staff delete permissions, status progression, image folder ownership, MIME type, file size, and staff photo cleanup.

## Android device smoke test

`integration_test/app_workflow_test.dart` requires generated Android files, Firebase options, and an emulator/device:

```powershell
flutter devices
flutter test integration_test/app_workflow_test.dart
```

The current smoke test checks the signed-out navigation path only. Registration, photo upload, student isolation, and staff moderation must still be demonstrated against the configured Firebase project.

Record actual command results and versions in `docs/technical_report.md`. Do not mark an unexecuted test as passing.