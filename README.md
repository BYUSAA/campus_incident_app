# Campus Incident Reporter

A Flutter + Firebase mobile application for reporting, tracking, and managing campus incidents such as damaged facilities, water interruptions, electrical faults, sanitation problems, and safety concerns.

> **Primary target:** Android emulator or physical Android device.  
> **Firebase setup:** Project-specific options must be generated locally; this repository intentionally does not contain fabricated Firebase credentials.

## Capabilities

### Students
- Register with an `@alustudent.com` address, verify the email, sign in, and sign out.
- Submit an incident with title, description, category, campus location, and optional image.
- Select an image from the gallery or camera and upload it to Firebase Storage.
- View, search, filter, and inspect personal reports.
- Edit or delete their own report while its status is `Submitted`.
- Follow the report status: `Submitted`, `In Progress`, or `Resolved`.

### Staff
- Sign in with a separate verified ALU account.
- Review the incident queue after a trusted administrator assigns the `staff` role.
- Update incident status and review report details.

### Engineering
- Provider-based state management and layered screen/provider/repository/service architecture.
- Firebase Authentication, Cloud Firestore, and Firebase Storage.
- Firestore and Storage security rules and Firestore index configuration.
- Unit/widget tests, device smoke-test scaffold, and GitHub Actions quality workflow.
- Technical report, architecture diagram source, and demo checklist.

## Architecture

```text
Flutter screens and shared widgets
              |
              v
        Provider state
              |
              v
          Repositories
              |
              v
      Firebase services
       /      |       \
      v       v        v
    Auth  Firestore  Storage
```

See [the architecture guide](docs/architecture/README.md) and [Mermaid source](docs/architecture/architecture_diagram.mmd).

## Repository map

| Location | Purpose |
| --- | --- |
| `lib/features/` | Authentication, home, incidents, profile, settings, and staff UI |
| `lib/models/` | User and incident data models |
| `lib/providers/` | Authentication, incident, and theme state |
| `lib/repositories/` | Application workflows and data mapping |
| `lib/services/` | Firebase SDK integrations |
| `lib/core/` | Routing, constants, validation, errors, and themes |
| `lib/shared/` | Reusable widgets and app navigation |
| `firebase/` | Firestore rules, Storage rules, and indexes |
| `docs/` | Technical report, architecture, screenshots, and demo script |
| `test/` | Unit and widget tests |
| `integration_test/` | Device-level smoke test |

## Requirements

Install Flutter (stable), Android Studio, Android SDK, an Android emulator or physical device, Node.js/npm, Firebase CLI, and FlutterFire CLI. Check your local toolchain:

```powershell
flutter doctor
flutter --version
dart --version
```

## 1. Clone the repository

```powershell
git clone https://github.com/BYUSAA/campus_incident_app.git
cd campus_incident_app
```

## 2. Generate Android runner files

The committed `android/` directory contains setup guidance rather than generated Gradle/Kotlin runner files. Generate them using your installed Flutter SDK:

```powershell
flutter create --platforms=android .
```

Review the generated Android application ID before registering the app in Firebase Console. Inspect the Git diff to ensure the existing Dart sources remain intact.

## 3. Configure Firebase

Install and sign in to Firebase CLI, then install FlutterFire CLI:

```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

Register the Android application ID with your Firebase project and run:

```powershell
flutterfire configure --platforms=android
```

This creates the real `lib/firebase_options.dart`. The committed options file is a fail-fast placeholder. Do not replace it with guessed IDs, keys, or sample credentials.

In Firebase Console, enable **Authentication → Email/Password**, create a **Cloud Firestore** database, and enable **Firebase Storage**. Confirm the Storage requirements for your Firebase plan.

## 4. Deploy backend configuration

Select the Firebase project that matches the generated FlutterFire options, then deploy:

```powershell
firebase use --add
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Check the selected project before deploying. Rules in GitHub are not active on a Firebase project until deployment succeeds.

## 5. Install, check, and run

```powershell
flutter pub get
dart format lib test integration_test
flutter analyze
flutter test
flutter run
```

Build an Android debug APK with:

```powershell
flutter build apk --debug
```

Report command outcomes only after the commands have actually completed. Record Flutter/Dart version and device details in the technical report.

## Student and staff roles

New accounts are always created as `student`. There is no in-app role switch.

For a staff demo account:
1. Register a separate ALU test account and verify its email.
2. Find its `users/{uid}` document in Firestore.
3. Have a trusted Firebase administrator change its `role` from `student` to `staff`.
4. Sign out and sign back in using the staff account.

Never let ordinary clients promote themselves. Route guards improve navigation; Firestore and Storage rules enforce actual authorization.

## Firestore data model

### `users/{uid}`

| Field | Type | Meaning |
| --- | --- | --- |
| `uid` | string | Firebase Authentication UID |
| `name` | string | Display name |
| `email` | string | ALU email |
| `role` | string | `student` or admin-assigned `staff` |
| `emailVerified` | boolean | Profile metadata; Auth token is authoritative |
| `createdAt` | timestamp | Creation timestamp |

### `incidents/{incidentId}`

| Field | Type | Meaning |
| --- | --- | --- |
| `title`, `description` | string | Report details |
| `category`, `location` | string | Incident type and campus location |
| `reportedBy` | string | Creator UID |
| `reporterName` | string | Name captured at submission |
| `status` | string | Submitted, In Progress, Resolved |
| `createdAt`, `updatedAt` | timestamp | Creation and update time |
| `imageUrl` | string/null | Optional image URL |
| `photoUrls` | string array | Image URL list |
| `assignedTo` | string/null | Optional staff assignment |

The model also reads older incident documents that contain only `imageUrl`.

## Security summary

- Incident access requires verified `@alustudent.com` authentication.
- Students read only reports they own; staff can read the incident queue.
- Students create reports only for themselves and with initial status `Submitted`.
- Students may edit report content without changing owner, creation time, or status.
- Staff updates are limited to status, assignment, and update timestamp.
- Users cannot change their own role.
- Images are stored at `incident_photos/{uid}/{fileName}`, limited to supported image MIME types and under 8 MB.

Review [firebase/README.md](firebase/README.md) before deploying rules or using real data.

## Final submission checklist

- [ ] Android runner files generated.
- [ ] FlutterFire options generated for the correct Firebase project.
- [ ] Email/Password Auth, Firestore, and Storage enabled.
- [ ] Rules and indexes deployed.
- [ ] Student register/verify/login and incident workflows tested.
- [ ] Gallery/camera photo upload tested.
- [ ] Separate staff account assigned by an administrator and status update tested.
- [ ] `flutter analyze`, `flutter test`, and Android debug build run and results recorded.
- [ ] Genuine screenshots added under `docs/screenshots/`.
- [ ] Demo video link added to `docs/technical_report.md`.

Use [the demo script](docs/demo_script.md) and [technical report](docs/technical_report.md). Hide personal information and credentials in evidence.

## Known boundaries

Firebase options and native Android runner files must be generated locally. Staff access requires trusted administrator assignment. Filtering currently operates on the loaded list; large deployments may require server-side pagination. Theme selection is in-memory and is not persisted between launches. Push notifications and offline submission are not included.

## License

See [LICENSE](LICENSE).


## Assignment 2 submission evidence

Use [the final submission checklist](docs/submission_checklist.md) to map the 55-point rubric to the evidence Canvas expects. The technical report draft is in [docs/technical_report.md](docs/technical_report.md), and the 7–10 minute recording outline is in [docs/demo_script.md](docs/demo_script.md).

Before the application can be demonstrated on Android, generate the native Android runner and configure the actual Firebase project as described above. The checked-in Firebase options file is intentionally a fail-fast placeholder; the app cannot initialize Firebase until FlutterFire generates the project-specific options. The most recent recorded GitHub Actions run on main failed, so inspect the workflow result and run the checks locally before submission. Add only real screenshots, test outcomes, Firebase evidence, and the recorded demo URL to the final PDF.
