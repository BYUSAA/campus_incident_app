# Assignment 2 — Final submission checklist

The rubric totals **55 points**. The report and video are mandatory deliverables, not optional extras.

## Must be completed on the student's computer

- [ ] Run flutter doctor and confirm the Android toolchain/emulator is ready.
- [ ] Generate Android runner files from the repository root: flutter create --platforms=android .
- [ ] Register the generated Android application ID in the correct Firebase project.
- [ ] Enable Email/Password in Firebase Authentication.
- [ ] Create/enable Cloud Firestore and Firebase Storage.
- [ ] Run flutterfire configure --platforms=android and use the generated lib/firebase_options.dart.
- [ ] Select the correct Firebase project and deploy: firebase deploy --only firestore:rules,firestore:indexes,storage.
- [ ] Register and verify an ALU student test account.
- [ ] Submit an incident with a photo and verify the Firestore document and Storage object.
- [ ] Create a separate staff account and have a trusted Firebase administrator set its users/{uid}.role to staff.
- [ ] Sign in as staff and update the same report status.
- [ ] Confirm the student can see the updated status and cannot access another student's reports.
- [ ] Run flutter pub get, dart format lib test integration_test, flutter analyze, flutter test, and flutter build apk --debug. Record the real output.
- [ ] Capture genuine Android screenshots for login, registration, verification, home, report form, report list/filter, details, staff dashboard, status update, and Firebase records. Hide private values.
- [ ] Record the required 7–10 minute demo showing all required workflows, then upload it and obtain a shareable URL.
- [ ] Add the screenshots and video URL to docs/technical_report.md.
- [ ] Export the completed technical report as a PDF and check the images, links, page breaks, and references.
- [ ] Name the PDF using the Canvas naming format: StudentName_Assignment2.pdf.
- [ ] Upload the PDF to Canvas before the assignment deadline.

## Rubric evidence map

| Rubric criterion | Points | Evidence expected |
| --- | ---: | --- |
| UI/UX | 6 | Polished Android workflows; explain design choices |
| Firebase Authentication | 6 | Registration, login, logout, verified ALU email, Firebase Console evidence |
| Firebase CRUD/backend | 6 | Firestore report creation, reading, updates, deletion/management, persistent records |
| State management/architecture | 8 | Provider usage, clear layers, synchronized state, architecture explanation |
| Feature implementation | 7 | Category, description, location, photo upload, search/filter, details, status |
| Technical explanation | 7 | Explain widgets, navigation, validation, async work, Provider, Firebase |
| Code quality | 5 | Readable layers, reusable components, tests, CI evidence |
| Report quality | 5 | PDF, data structure, diagrams, genuine screenshots, security, testing, IEEE/APA references |
| Product thinking | 5 | Campus relevance, privacy, role separation, original decisions |

## Important repository blockers found during review

1. Android runner files are not present; the Android folder contains setup instructions only.
2. lib/firebase_options.dart is a deliberate placeholder and throws until FlutterFire is configured for the actual Firebase project.
3. The most recent GitHub Actions run on main was marked failed. Inspect its failure and obtain a passing run after fixes.
4. The repository has screenshot placeholders and no actual 7–10 minute demo URL.

These items require access to the student's Android/Firebase environment or genuine student-recorded evidence. Do not replace them with fabricated screenshots, credentials, test outcomes, or video.
