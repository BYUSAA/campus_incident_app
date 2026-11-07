# Assignment 2 — Final submission checklist

The rubric totals **55 points**. The technical report PDF, GitHub repository, and 7–10 minute demo video are mandatory deliverables.

## Local Android and Firebase setup

- [ ] Run `flutter doctor -v` and confirm Android Studio, SDK, and emulator/device are ready.
- [ ] Run `tooling/bootstrap-android.ps1` to generate the Android runner.
- [ ] Confirm the actual application ID in `android/app/build.gradle.kts` and register it in Firebase Console.
- [ ] Enable Email/Password in Firebase Authentication.
- [ ] Create/enable Cloud Firestore and Firebase Storage.
- [ ] Run `tooling/bootstrap-firebase.ps1 -ProjectId YOUR_FIREBASE_PROJECT_ID`.
- [ ] Confirm FlutterFire generated the Android options in `lib/firebase_options.dart`.
- [ ] Verify that the Firebase CLI target is the intended project.
- [ ] Deploy Firestore rules/indexes and Storage rules; confirm both deployments succeed.

## Functional and security verification

- [ ] Register and verify an ALU student test account.
- [ ] Submit an incident with a photo and verify the Firestore document and Storage object.
- [ ] Test search, status filters, report details, and the status timeline.
- [ ] Confirm the student cannot read another student's report.
- [ ] Confirm a student cannot promote their role or change report status.
- [ ] Confirm students can edit/delete only reports still in `Submitted`.
- [ ] Create a separate verified staff account and have a trusted administrator assign the `staff` role.
- [ ] Confirm staff can read the queue and progress reports `Submitted` → `In Progress` → `Resolved`.
- [ ] Confirm status cannot move backwards.
- [ ] Confirm staff can read and clean up photo evidence when moderating a report.
- [ ] Test camera and gallery selection on Android.

## Automated tests and build

- [ ] Run `flutter pub get`.
- [ ] Run `dart format lib test integration_test`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Run `flutter build apk --debug`.
- [ ] Run the Firebase Emulator Suite rules tests from `firebase/rules-tests/`.
- [ ] Run the device integration smoke test on the configured Android target.
- [ ] Record actual command results and environment versions in the technical report.

## Screenshots, video, and PDF

- [ ] Capture genuine Android screenshots: login, registration, verification, home, report form/photo, report list/filter, details, staff dashboard, and status update.
- [ ] Capture Firebase Auth, Firestore, and Storage evidence using test data.
- [ ] Hide emails, UIDs, credentials, download tokens, and private project details.
- [ ] Record a 7–10 minute video showing the student and staff workflows.
- [ ] Upload the video and add its accessible URL to `docs/technical_report.md`.
- [ ] Complete the report's actual test-result table.
- [ ] Export the completed report as a PDF and check diagrams, screenshots, links, page breaks, and references.
- [ ] Name the PDF `StudentName_Assignment2.pdf` using the Canvas naming format.
- [ ] Upload the PDF through Canvas before the deadline.

## Rubric evidence map

| Rubric criterion | Points | Evidence expected |
| --- | ---: | --- |
| UI/UX | 6 | Polished Android workflows; explain design choices |
| Firebase Authentication | 6 | Registration, login, logout, verified ALU email, Firebase Console evidence |
| Firebase CRUD/backend | 6 | Firestore create/read/update/delete or report management, persistent records |
| State management/architecture | 8 | Provider usage, clean layers, synchronized state, architecture explanation |
| Feature implementation | 7 | Category, description, location, photo upload, search/filter, details, status |
| Technical explanation | 7 | Explain widgets, navigation, validation, async work, Provider, Firebase |
| Code quality | 5 | Readable structure, reusable components, tests, CI evidence |
| Report quality | 5 | PDF, diagrams, genuine screenshots, security, testing, IEEE/APA references |
| Product thinking | 5 | Campus relevance, privacy, role separation, original decisions |

## Important truth about evidence

Android runner files and Firebase options are generated in the student's local environment. Screenshots, Firebase records, actual test outcomes, and the video must come from the real configured app. Do not replace them with fabricated evidence. A GitHub Actions workflow is configured to generate an Android runner temporarily and build a debug APK in CI, but that does not generate the local Android project or replace the real-device demonstration.