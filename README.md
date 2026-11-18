# Campus Incident Reporter

A Flutter Android application for reporting, tracking, and managing campus incidents such as damaged facilities, water interruptions, electrical faults, sanitation problems, and safety concerns.

**Primary platform:** Android
**Backend:** Firebase Authentication, Cloud Firestore, Cloudflare R2 (incident photos, via a Cloudflare Worker)
**State management:** Provider (`ChangeNotifier`)
**Navigation:** `go_router`
**Workflow:** Submitted → In Progress → Resolved

> `lib/firebase_options.dart` holds the Firebase **client** configuration for the project the app is connected to. It is not a secret (access is enforced by Firestore rules and the photo Worker), but if you use your own Firebase project, regenerate it as described below. No Admin SDK credentials, service-account keys, or passwords are committed.

> **Why Cloudflare for photos?** Firebase Storage requires the paid Blaze plan for new projects. Photos are stored in Cloudflare R2 instead, behind a small Worker (`cloudflare/photo-worker.js`) that applies the same access rules the Firebase Storage rules did. Authentication and Firestore stay on the free Firebase Spark plan.

## Student and staff workflows

### Students
- Register with a valid `@alustudent.com` address, verify the email, and reset a forgotten password.
- Submit reports with title, description, category, location, and an optional photo.
- Upload incident photos (JPG, PNG, or WebP under 8 MB) from the camera or gallery; they are stored privately in Cloudflare R2.
- View, search, filter, and inspect their own reports.
- Edit or delete their own report while its status is `Submitted`, including replacing or removing an attached photo.
- Update their profile display name without changing protected account fields.
- Choose light/dark appearance; the preference is saved on the device.
- Follow the status updates made by authorized staff.

### Authorized staff
- Sign in with a separate verified ALU account assigned the `staff` role by a trusted Firebase administrator.
- Review the campus incident queue.
- Move report status forward: `Submitted` → `In Progress` → `Resolved`. Staff choose the next status, then confirm with **Update status**; statuses that are not the next step are disabled.
- Delete a report and its photo with **Delete report**, which always asks for confirmation so a report is not removed by accident instead of being updated.

There is no client-side role promotion. Firestore rules and the photo Worker, not hidden navigation controls, enforce ownership and staff access.

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
               Services
             /     |      \
            v      v       v
      Firebase   Cloud    Cloudflare Worker
        Auth   Firestore  (verifies Firebase ID token)
                               |
                               v
                         Cloudflare R2
                        (incident photos)
```

| Layer | Location | Responsibility |
| --- | --- | --- |
| Presentation | `lib/features/`, `lib/shared/` | Screens, reusable widgets (incl. `IncidentPhoto`), forms, navigation |
| State | `lib/providers/` | Authentication, incident streams, theme |
| Workflows | `lib/repositories/` | Registration and incident operations |
| Service adapters | `lib/services/` | Firebase Authentication, Firestore, photo Worker (`StorageService`) |
| Models | `lib/models/` | User and incident mapping |
| Core | `lib/core/` | Routes, validation, theme, status and photo-storage constants |
| Backend rules | `firebase/` | Firestore access control and indexes |
| Photo backend | `cloudflare/` | Worker that guards the R2 photo bucket |
| Tests and evidence | `test/`, `integration_test/`, `docs/` | Automated tests, report, screenshots, demo |

See [the architecture guide](docs/architecture/README.md) and [Mermaid diagram](docs/architecture/architecture_diagram.mmd).

## Requirements

Install Flutter stable, Android Studio and Android SDK, an Android emulator or physical device, Node.js 22+, npm, **JDK 17 or JDK 21**, Firebase CLI, and FlutterFire CLI. JDK 17 is used by the repository's CI workflow.

### Android Java / Gradle compatibility

The Android project currently uses Gradle 8.14.3 and Android Gradle Plugin 8.13.2. Use JDK 17 (the CI version) or JDK 21 for local Android builds. **JDK 25 is not compatible with the committed Gradle 8.14.3 wrapper**; changing Dart source files will not fix this toolchain error, and upgrading only the Gradle wrapper is not a safe substitute.

On Windows, configure Flutter to use an installed JDK 17 or 21. Replace the example path with the actual JDK directory on your computer (the directory containing `bin\\java.exe` and `bin\\javac.exe`):

```powershell
flutter config --jdk-dir="C:\\path\\to\\jdk-17-or-21"
flutter doctor -v
```

Check the Java version reported under **Android toolchain** in `flutter doctor -v` before running the app. This Flutter setting is stored on the developer's machine and should not be committed to the repository.

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

## 2. Android platform

The native Android application runner is committed in `android/`, including the application manifest, Kotlin `MainActivity`, Gradle project configuration, launcher resource, and themes. The Android application ID is `com.byusa.campus_incident_reporter`; the minimum supported Android API is 24.

Run the app on an Android emulator or physical device from the repository root:

```powershell
flutter pub get
flutter devices
flutter run
```

Build a debug APK:

```powershell
flutter build apk --debug
```

The Gradle wrapper distribution is pinned in `android/gradle/wrapper/gradle-wrapper.properties`. Flutter's Android tooling supplies wrapper launch scripts when invoking Flutter build commands. Do not add local SDK paths or signing credentials to source control.

## 3. Configure Firebase

In Firebase Console, register the Android application ID and enable:
- Authentication → Sign-in method → Email/Password
- Cloud Firestore — create the **(default)** database in production mode

Firebase Storage is **not** used (photos go to Cloudflare R2, see step 5), so the project can stay on the free Spark plan.

The app reads its Firebase settings from `lib/firebase_options.dart`. To point the app at a different Firebase project, regenerate that file. Run from the repository root using your actual Firebase project ID:

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

If the FlutterFire CLI is not available, the same values can be copied from the `google-services.json` downloaded from Firebase Console (Project settings → Your apps → Android): `api_key.current_key` → `apiKey`, `mobilesdk_app_id` → `appId`, `project_number` → `messagingSenderId`, `project_id` → `projectId`, `storage_bucket` → `storageBucket`. Keep `android/app/google-services.json` out of source control (it is in `.gitignore`).

Use the same Firebase project for FlutterFire configuration and rules deployment. `firebase_options.dart` contains client configuration, not Admin SDK credentials. After `flutter pub get`, commit the generated `pubspec.lock` so the app's resolved dependency versions are reproducible. Never commit service-account JSON, private keys, or passwords.

## 4. Deploy Firestore security rules and index

Rules in source control are not active on a live project until they are deployed. Review `firebase/README.md` first.

**Option A — Firebase CLI:**

```powershell
firebase login
firebase projects:list
firebase deploy --project YOUR_FIREBASE_PROJECT_ID --only firestore:rules,firestore:indexes
```

**Option B — Firebase Console (no CLI):**

1. **Firestore Database → Rules:** paste the contents of `firebase/firestore.rules` and click **Publish**.
2. **Firestore Database → Indexes → Add index** (shown as a *structured* index in newer consoles):
   collection ID `incidents` (plural), fields `reportedBy` Ascending and `createdAt` Descending, query scope **Collection**. Wait until it shows **Enabled**.

Until the index is enabled, the student report list shows *"The query requires an index"*. Firestore also logs a link that creates the exact index; with a device connected, find it with `adb logcat | findstr create_composite`.

## 5. Set up photo storage (Cloudflare R2 + Worker)

Incident photos are uploaded to a private Cloudflare R2 bucket through the Worker in `cloudflare/photo-worker.js`. The app sends the signed-in user's Firebase ID token with every photo request; the Worker verifies it against Google's public keys and enforces:

- only verified `@alustudent.com` accounts may use it;
- users upload only into their own folder, `photos/{uid}/{fileName}`;
- the owner and staff (`users/{uid}.role == 'staff'`, read from Firestore) may view and delete a photo;
- only JPEG, PNG, or WebP images under 8 MB are accepted.

Everything can be done in the Cloudflare dashboard (<https://dash.cloudflare.com>):

1. **Enable R2:** Storage & databases → **R2 Object Storage** → enable it (Cloudflare asks for a card even for the free tier). Note that **KV** is a different product and is not used.
2. **Create the bucket:** R2 → **Create bucket** → name `incident-photos`, location Automatic. Keep public access **off**.
3. **Create the Worker:** Compute (Workers) → Workers & Pages → **Create** → **Start with Hello World** → name `incident-photos-api` → **Deploy** → **Edit code**, replace everything with the contents of `cloudflare/photo-worker.js`, then **Deploy**.
4. **Connect the bucket and project:** open the Worker → **Settings**:
   - Bindings → Add → **R2 bucket**: variable name `PHOTOS`, bucket `incident-photos`.
   - Variables and Secrets → Add → **Text**: `FIREBASE_PROJECT_ID` = your Firebase project ID.
   - Click **Deploy** after each change.
5. **Check it:** open `https://<your-worker>.workers.dev/photos/test/test.jpg` in a browser. The expected response is `{"error":"Missing sign-in token"}`. If it says `Worker is missing PHOTOS or FIREBASE_PROJECT_ID`, recheck step 4.
6. **Point the app at your Worker:** the default URL is set in `lib/core/constants/photo_storage.dart`. Either edit `defaultValue` there, or override it at build time:

   ```powershell
   flutter run --dart-define=PHOTO_API_URL=https://<your-worker>.workers.dev
   ```

The Worker URL is not a secret — every request is checked against the caller's Firebase sign-in. No Cloudflare API keys are stored in the app.

## 6. Run and verify the app

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
| `imageUrl` | string/null | Optional photo URL served by the photo Worker (`https://<worker>/photos/{uid}/{fileName}`) |
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
- Photos are stored in R2 under `photos/{uid}/{fileName}`, limited to JPEG/PNG/WebP images smaller than 8 MB. The Worker enforces this.
- Photo URLs are useless without a valid Firebase sign-in token; only the owner and staff can view or delete a photo.
- Staff may read/delete evidence for reports they moderate.

## Automated tests

### Flutter unit/widget tests

```powershell
flutter test
```

Coverage includes input validation, incident model mapping, status progression, Provider stream behavior, required incident form validation, and incident card rendering.

### Firebase Emulator Suite rules tests

Requirements: Node.js 22+, **Java 21+** (the Firebase CLI's emulators no longer run on Java 17), Firebase CLI.

```powershell
cd firebase/rules-tests
npm install
cd ../..
firebase emulators:exec --project demo-campus-incident-reporter --only firestore,storage "npm --prefix firebase/rules-tests test"
```

These tests use the local Firestore and Storage emulators with a `demo-` project ID, not the production Firebase project. They cover student ownership, role self-promotion, email verification, report lifecycle, photo ownership, MIME type, size limit, and staff evidence cleanup.

> `firebase/storage.rules` and its tests are kept for reference, in case the project later moves to the Blaze plan and back to Firebase Storage. The running app does not use Firebase Storage; photo access rules are enforced by `cloudflare/photo-worker.js`.

### Device integration smoke test

After Android and Firebase configuration:

```powershell
flutter devices
flutter test integration_test/app_workflow_test.dart
```

The current device smoke test checks the signed-out redirect only. It does not replace the complete student/staff workflow demonstrated in the video.

## Staff test account

1. Register a second ALU test account and verify its email.
2. In Firebase Console → Firestore Database → Data → `users`, find the document whose `email` matches that account.
3. Have a trusted Firebase administrator edit its `role` field from `student` to `staff` (lowercase).
4. Sign out and sign back in with the staff account — the role is read at sign-in. The app opens the Staff Dashboard.
5. Demonstrate the queue, status progression (choose a status → **Update status**), report photo access, and the delete confirmation.

Never add a client-side self-promotion switch or commit administrator credentials.

## Assignment submission

The repository includes an editable IEEE-style technical report source covering the architecture, data model, state management, roles, security, UI/UX, testing strategy, lessons learned, and references. A formatted PDF draft is provided separately; it clearly labels unverified live Firebase/device checks and genuine screenshot/video placeholders. Use:
- [Technical report source](docs/technical_report.md)
- [Demo script](docs/demo_script.md)
- [55-point rubric checklist](docs/submission_checklist.md)
- [Screenshot evidence guide](docs/screenshots/README.md)

Capture genuine screenshots from the configured Android app and Firebase Console. Add the real video URL and verified test outcomes to the report before submitting the final PDF with the Canvas naming format `StudentName_Assignment2.pdf`.

## Known limitations

- The Android runner is committed in source control. Firebase options remain project-specific and must be generated for the real Firebase project; no credentials or project IDs are fabricated.
- Search and status filters operate on the reports loaded into the client; pagination/server-side search would be needed for larger deployments.
- Push notifications, offline submission, pagination/server-side search, and a full staff assignment workflow are not implemented.
- The integration smoke test is narrower than the full manual demonstration.
- Photos depend on two providers (Firebase for sign-in and data, Cloudflare for files). If the Worker is unreachable, reports still load but photos show a placeholder and uploads fail with a clear error after a 60-second timeout.
- Photos uploaded to Firebase Storage before the move to Cloudflare are not migrated.

## Troubleshooting

| Symptom | Cause / fix |
| --- | --- |
| App shows **"Connect your Firebase project"** | `lib/firebase_options.dart` is still the placeholder. See step 3. |
| Student report list shows **"The query requires an index"** | The `incidents` composite index is missing, still building, or was created on the wrong collection name (it must be `incidents`). See step 4. |
| Sign-up or submit spins forever | The device cannot reach Google's servers — e.g. mobile data stuck behind a carrier captive portal. Switch to Wi-Fi or open a browser on the phone to clear the portal. |
| Photo shows a broken-image icon | Check the Worker URL in `lib/core/constants/photo_storage.dart` and the Worker's `PHOTOS` / `FIREBASE_PROJECT_ID` settings (step 5). |
| Phone keeps disconnecting from `adb`/`flutter run` while using **scrcpy** | scrcpy ships its own `adb` that conflicts with the Android SDK's. Run `setx ADB "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"` once and reopen the terminal. |

## License

See [LICENSE](LICENSE).