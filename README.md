# Campus Incident Reporter

A Flutter and Firebase mobile application for reporting and following up on incidents that affect safety, facilities, sanitation, water, electricity, and the wider campus environment.

The project is organized around a clear separation of responsibilities:

**Flutter screens → Provider state → repositories → Firebase services**

Android is the intended demonstration target. Firebase is configured per project; this repository deliberately does not contain fabricated Firebase credentials.

## What the application supports

- Student registration using an **@alustudent.com** email address.
- Firebase email/password sign-in and email verification.
- Session restoration and sign-out.
- Student and staff roles, with new accounts always created as students.
- Incident submission with a title, description, category, location, and optional photo.
- Photo selection from the gallery or camera and upload to Firebase Storage.
- Real-time incident lists, search, status filtering, and report details.
- Editing and deleting a student's own report while it remains in the Submitted state.
- A staff dashboard for reviewing reports and updating status to Submitted, In Progress, or Resolved.
- Firestore and Storage security rules that enforce access outside the UI.
- A light/dark appearance setting.

## Repository structure

| Path | Purpose |
| --- | --- |
| `lib/features/` | Authentication, home, incident, profile, settings, and staff screens |
| `lib/providers/` | ChangeNotifier state for authentication, incidents, and theme |
| `lib/repositories/` | Authentication, user-profile, and incident workflows |
| `lib/services/` | Firebase Authentication, Firestore, Storage, and email verification |
| `lib/models/` | User and incident data models |
| `lib/core/` | Shared constants, validation, routing, errors, and themes |
| `lib/shared/` | Reusable widgets and the main navigation scaffold |
| `firebase/` | Firestore rules, Storage rules, and Firestore indexes |
| `docs/` | Technical report, architecture explanation, screenshots folder, and demo plan |
| `test/` | Unit and widget tests |
| `integration_test/` | Android device-level smoke test |

## Requirements

Install the Flutter SDK and Android Studio with an Android SDK and emulator or physical Android device. Verify the toolchain:

```bash
flutter doctor
flutter --version
dart --version
```

Install the Firebase CLI and FlutterFire CLI:

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

The repository's `android/` directory currently contains setup guidance rather than generated Gradle/Kotlin project files. Generate Android platform scaffolding once from the project root:

```bash
flutter create --platforms=android .
```

This generates native Android files for the Flutter SDK installed on your computer. Review the generated Android application ID before registering the Android app in Firebase.

## Firebase setup

1. Create or select a Firebase project that you control.
2. Add an Android app in Firebase Console using the Android application ID generated for this project.
3. From the repository root, run:

   ```bash
   flutterfire configure --platforms=android
   ```

   This generates `lib/firebase_options.dart` for your real Firebase project. Do not replace it with example or guessed keys.

4. In Firebase Console, enable **Authentication → Email/Password**.
5. Create a Cloud Firestore database.
6. Enable Firebase Storage and confirm the Storage requirements for your Firebase plan.
7. Deploy the included rules and indexes:

   ```bash
   firebase use --add
   firebase deploy --only firestore:rules,firestore:indexes,storage
   ```

8. Install dependencies and run on Android:

   ```bash
   flutter pub get
   flutter run
   ```

The app and Firebase rules both enforce the student email domain `@alustudent.com`. Update the app validator and both rule files together only when the assignment owner authorizes another domain.

## Student and staff access

A newly registered user is always assigned the `student` role. The application does not provide a role switch.

To prepare a staff demonstration account:

1. Register a separate ALU test account and verify its email.
2. In Firebase Console, locate `users/{uid}` for that test account.
3. Using an administrator account, change its `role` field from `student` to `staff`.
4. Sign out and sign in with the staff account.

Never let an ordinary client edit its own role. Firebase rules check the role stored in the user's profile; hiding staff buttons in Flutter is not an access-control boundary.

## Data model

### `users/{uid}`

| Field | Type | Notes |
| --- | --- | --- |
| `uid` | string | Firebase Authentication UID |
| `name` | string | Display name |
| `email` | string | ALU email used for sign-in |
| `role` | string | `student` or administrator-assigned `staff` |
| `emailVerified` | boolean | Initial profile flag; Firebase Auth token is authoritative for access |
| `createdAt` | timestamp | Server timestamp |

### `incidents/{incidentId}`

| Field | Type | Notes |
| --- | --- | --- |
| `title` | string | Brief incident title |
| `description` | string | Incident details |
| `category` | string | Facilities, Water, Electricity, Safety, or Sanitation |
| `location` | string | Campus location |
| `reportedBy` | string | Creator's Firebase UID |
| `reporterName` | string | Name captured at submission |
| `status` | string | Submitted, In Progress, or Resolved |
| `createdAt` | timestamp | Creation time |
| `updatedAt` | timestamp | Last update time |
| `imageUrl` | string or null | Optional photo URL |
| `photoUrls` | string array | Supports future multiple-photo records |
| `assignedTo` | string or null | Optional staff assignment |

Older records that contain only `imageUrl` remain readable by the model.

## Security model

- Unverified or non-ALU accounts cannot read or write incident data.
- A student can read only incidents whose `reportedBy` matches their UID.
- Staff can read all incidents when the trusted staff role is assigned.
- Students can create reports only for themselves and cannot set an initial status other than Submitted.
- Students may edit report details without changing ownership, creation time, or status.
- Staff may update status and assignment fields, but cannot rewrite ownership.
- A user cannot change their own role in Firestore.
- Storage uploads are scoped to `incident_photos/{uid}/`, constrained to image content types and files smaller than 8 MB.

Deploy these rules to the same Firebase project used by `flutterfire configure`. Rules stored in GitHub do not become active until deployed.

## Verification

Run these commands locally after generating Android scaffolding and Firebase configuration:

```bash
flutter pub get
dart format lib test integration_test
flutter analyze
flutter test
flutter build apk --debug
```

The unit and widget tests cover model mapping, input validation, provider stream handling with a fake repository, and incident-card rendering. The device integration smoke test requires a configured Firebase project and an Android device/emulator.

The repository does not claim these commands passed until they are run in a Flutter environment. Firebase integration and device behavior must also be checked with the configured project.

## Evidence to add before submission

Add genuine screenshots to `docs/screenshots/` and link the actual demo video in `docs/technical_report.md`. The demo should show student registration/verification, sign-in, report creation with a photo, searching/filtering, viewing a report, and staff status management. Include Firebase Console evidence with personal information, credentials, and private identifiers hidden.

Use `docs/demo_script.md` as the walkthrough guide and `docs/technical_report.md` as the submission report.

## Current setup boundary

The generated Firebase configuration is project-specific. `lib/firebase_options.dart` remains a fail-fast placeholder until `flutterfire configure` is run. Android/iOS/desktop platform directories also require native scaffolding from the local Flutter SDK. These project-specific artifacts cannot be generated correctly without the owner's Firebase project and local toolchain.

## License

See [LICENSE](LICENSE).
