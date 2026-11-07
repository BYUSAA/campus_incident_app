# Campus Incident Reporter

A Flutter Android application for reporting, tracking, and managing campus incidents such as damaged facilities, water interruptions, electrical faults, sanitation problems, and safety concerns.

**Primary platform:** Android
**Backend:** Firebase Authentication, Cloud Firestore, Firebase Storage
**FlutterFire release set:** Firebase Flutter BoM 5.1.0
**State management:** Provider (`ChangeNotifier`)
**Navigation:** `go_router`
**Workflow:** Submitted → In Progress → Resolved

> Firebase project options are generated for the project selected by the developer. No Firebase IDs, API keys, or Admin SDK credentials are invented or committed here.

## Student and staff workflows

### Students
- Register with a valid `@alustudent.com` address, verify the email, and reset a forgotten password.
- Submit reports with title, description, category, location, and an optional photo.
- Upload incident photos from the camera or gallery to Firebase Storage.
- View, search, filter, and inspect their own reports.
- Edit or delete their own report while its status is `Submitted`, including replacing or removing an attached photo.
- Update their profile display name without changing protected account fields.
- Choose light/dark appearance; the preference is saved on the device.
- Follow the status updates made by authorized staff.

### Authorized staff
- Sign in with a separate verified ALU account assigned the `staff` role by a trusted Firebase administrator.
- Review the campus incident queue.
- Move report status forward: `Submitted` → `In Progress` → `Resolved`.
- Moderate reports, progress each status in sequence, and delete a report with its associated evidence when necessary.

There is no client-side role promotion. Firebase rules, not hidden navigation controls, enforce ownership and staff access.

## Architecture

```text
Flutter feature screens and shared widgets
                  |
                  v
            Provider state
                  |
                  v
              Repositories
                  |
                  v
             Firebase services
             /       |        \
            v        v         v
       Firebase   Cloud      Firebase
         Auth    Firestore   Storage
```

| Layer | Location | Responsibility |
| --- | --- | --- |
| Presentation | `lib/features/`, `lib/shared/` | Screens, reusable widgets, forms, navigation |
| State | `lib/providers/` | Authentication, incident streams, theme |
| Workflows | `lib/repositories/` | Registration and incident operations |
| Firebase adapters | `lib/services/` | Authentication, Firestore, Storage |
| Models | `lib/models/` | User and incident mapping |
| Core | `lib/core/` | Routes, validation, theme, status constants |
| Backend rules | `firebase/` | Firestore/Storage access control and indexes |
| Tests and evidence | `test/`, `integration_test/`, `docs/` | Automated tests, report, screenshots, demo |

See [the architecture guide](docs/architecture/README.md) and [Mermaid diagram](docs/architecture/architecture_diagram.mmd).

## Requirements

Install Flutter 3.47.0 or newer (Dart 3.13.0 or newer), Android Studio and Android SDK, an Android emulator or physical device, Node.js 22+, npm, Java 17+, Firebase CLI, and FlutterFire CLI.

```powershell
flutter doctor -v
flutter --version
dart --version
java -version
node --version
npm --version
```

## 1. Clone the repository

```powershell
git clone https://github.com/BYUSAA/campus_incident_app.git
cd campus_incident_app
```

## 2. Generate the Android platform

The Git repository contains Android setup guidance rather than generated Gradle/Kotlin runner files. Generate the runner on the Windows development computer:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tooling\bootstrap-android.ps1
```

The script generates the runner only if it is missing, sets and verifies Android `minSdk` 24 required by `image_picker` 1.2.4, installs Flutter dependencies, and prints the Android application ID. With the current Flutter project name and the `com.byusa` organization prefix, the expected ID is `com.byusa.campus_incident_reporter`. Confirm the actual value in `android/app/build.gradle.kts` before registering the Android app in Firebase Console.

If you generate the Android runner manually instead of using the script, set `minSdk = 24` in `android/app/build.gradle.kts` (or `minSdkVersion 24` in Groovy Gradle) before building. `image_picker` 1.2.4 requires Android API 24 or newer.

## 3. Configure Firebase

In Firebase Console, register the Android application ID and enable:
- Authentication → Sign-in method → Email/Password
- Cloud Firestore
- Cloud Storage

Then run from the repository root using your actual Firebase project ID:

```powershell
.\tooling\bootstrap-firebase.ps1 -ProjectId YOUR_FIREBASE_PROJECT_ID
```

The script checks Firebase CLI login, installs FlutterFire CLI, runs `flutterfire configure --project ... --platforms=android`, and verifies that `lib/firebase_options.dart` is no longer the setup placeholder. It asks you to type `YES` before deploying any backend rules.

Manual alternative:

```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project YOUR_FIREBASE_PROJECT_ID --platforms=android
```

Use the same Firebase project for FlutterFire configuration and CLI deployment. The generated `firebase_options.dart` contains client configuration, not Admin SDK credentials. After `flutter pub get`, commit the generated `pubspec.lock` so the app's resolved dependency versions are reproducible. Never commit service-account JSON, private keys, or passwords.

## 4. Deploy security rules and indexes

Confirm the intended Firebase project before deploying:

```powershell
firebase projects:list
firebase deploy --project YOUR_FIREBASE_PROJECT_ID --only firestore:rules,firestore:indexes,storage
```

Rules in source control are not active on a live project until deployment succeeds. Review `firebase/README.md` first. Storage rules use a Firestore role lookup for staff access; deploy Firestore and Storage rules to the same Firebase project.

## 5. Run and verify the app

```powershell
flutter pub get
dart format lib test integration_test
flutter analyze
flutter test
flutter build apk --debug
flutter devices
flutter run
```

For a single local verification run after setup, use:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tooling\verify-project.ps1
```

This script resolves dependencies, formats Dart files, runs static analysis and Flutter tests, runs Firestore/Storage rules tests in local emulators, builds the Android debug APK, and runs the signed-out integration smoke test when an Android device is connected. It stops at the first failing step and prints the exact stage to fix. Review and commit the generated `pubspec.lock` and `firebase/rules-tests/package-lock.json` afterward.

The assignment requires Android or iOS runtime evidence. A browser-only run does not replace the Android emulator or physical-device demonstration.

## Firebase data model

### `users/{uid}`

| Field | Type | Meaning |
| --- | --- | --- |
| `uid` | string | Firebase Authentication UID |
| `name` | string | Profile name, 1–80 characters |
| `email` | string | ALU student email |
| `role` | string | `student` or administrator-assigned `staff` |
| `emailVerified` | boolean | Profile metadata; Auth token claim is authoritative |
| `createdAt` | timestamp | Server creation time |

### `incidents/{incidentId}`

| Field | Type | Meaning |
| --- | --- | --- |
| `title` | string | 1–100 characters |
| `description` | string | 1–1,000 characters |
| `category` | string | Facilities, Water, Electricity, Safety, or Sanitation |
| `location` | string | 1–160 characters |
| `reportedBy` | string | Creator UID |
| `reporterName` | string | Creator's name at submission |
| `status` | string | Submitted, In Progress, or Resolved |
| `createdAt`, `updatedAt` | timestamp | Server-side times |
| `imageUrl` | string/null | Optional Storage download URL |
| `photoUrls` | string array | Zero or one photo in the current app |
| `assignedTo` | string/null | Optional staff assignment |

The student feed filters by `reportedBy` and orders by `createdAt` descending. Its composite index is in `firebase/firestore.indexes.json`.

## Authorization summary

- Incident operations require verified `@alustudent.com` email.
- Students can read only their own reports; staff can read all reports.
- Students create their own reports with initial status `Submitted`.
- Students can edit or delete their own reports only while they remain `Submitted`.
- Students cannot change report status, owner, reporter identity, or creation time.
- Staff can progress reports only from Submitted to In Progress and then Resolved.
- Users cannot promote themselves to staff.
- Photos are stored under `incident_photos/{uid}/{fileName}`, limited to supported images smaller than 8 MB.
- Staff may read/delete evidence for reports they moderate.

## Automated tests

### Flutter unit/widget tests

```powershell
flutter test
```

Coverage includes input validation, incident model mapping, status progression, Provider stream behavior, required incident form validation, and incident card rendering.

### Firebase Emulator Suite rules tests

Requirements: Node.js 22+, Java 17+, Firebase CLI.

```powershell
cd firebase/rules-tests
npm install
cd ../..
firebase emulators:exec --project demo-campus-incident-reporter --only firestore,storage "npm --prefix firebase/rules-tests test"
```

These tests use the local Firestore and Storage emulators with a `demo-` project ID, not the production Firebase project. They cover student ownership, role self-promotion, email verification, report lifecycle, photo ownership, MIME type, size limit, and staff evidence cleanup.

### Device integration smoke test

After Android and Firebase configuration:

```powershell
flutter devices
flutter test integration_test/app_workflow_test.dart
```

The current device smoke test checks the signed-out redirect only. It does not replace the complete student/staff workflow demonstrated in the video.

## Staff test account

1. Register a second ALU test account and verify its email.
2. Locate the account's `users/{uid}` document in Firestore.
3. Have a trusted Firebase administrator change its role from `student` to `staff`.
4. Sign out and sign back in with the staff account.
5. Demonstrate the queue, status progression, and report photo access.

Never add a client-side self-promotion switch or commit administrator credentials.

## Assignment submission

The assignment requires a **PDF technical report** and a **7–10 minute demonstration video**. Use:
- [Technical report draft](docs/technical_report.md)
- [Demo script](docs/demo_script.md)
- [55-point rubric checklist](docs/submission_checklist.md)
- [Screenshot evidence guide](docs/screenshots/README.md)

Capture genuine screenshots from your configured Android app and Firebase Console. Add the real video URL and test outcomes, export the completed report as PDF, and use the Canvas naming format `StudentName_Assignment2.pdf`.

## Known limitations

- Android runner files and Firebase options are generated on the developer's computer; they are not fabricated in this repository.
- Search and status filters operate on the reports loaded into the client; pagination/server-side search would be needed for larger deployments.
- Push notifications, offline submission, pagination/server-side search, and a full staff assignment workflow are not implemented.
- The integration smoke test is narrower than the full manual demonstration.

## License

See [LICENSE](LICENSE).