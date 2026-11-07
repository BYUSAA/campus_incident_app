# Project documentation

This folder contains the technical explanation, report PDF draft, and submission evidence plan for Individual Assignment 2.

## Contents

- `Byusa_Martin_De_Poles_Assignment2.pdf`: formatted IEEE-style technical report PDF draft; it clearly labels unverified Firebase/runtime checks and screenshot/video placeholders.
- `technical_report.md`: editable technical report source covering problem, users, architecture, Firebase data, authorization, Provider, UI/UX, testing, limitations, repository URL, video placeholder, and IEEE references.
- `demo_script.md`: 7–10 minute Android demonstration sequence covering student and staff workflows.
- `submission_checklist.md`: rubric-to-evidence map and final Canvas checklist.
- `architecture/`: architecture explanation and editable Mermaid diagram.
- `screenshots/`: instructions and suggested filenames for genuine app/Firebase evidence.

## Complete the submission

1. Confirm the committed Android project is present under `android/` and the application ID is `com.byusa.campus_incident_reporter`.
2. Configure the actual Firebase project with `tooling/bootstrap-firebase.ps1`.
3. Verify Email/Password Authentication, Firestore, and Storage are enabled.
4. Deploy the Firestore rules, index, and Storage rules to the intended project.
5. Run Flutter tests and Firebase Emulator Suite security-rule tests.
6. Run student and separate staff workflows on an Android emulator or physical device.
7. Capture screenshots from the real app and Firebase Console.
8. Record the 7–10 minute demo and replace the report's video placeholder.
9. Record actual test outcomes, export the report to PDF, and submit the PDF through Canvas.

The Android native runner is already committed. Firebase app options still need to be generated for the real Firebase project. Do not invent test results, screenshots, Firebase records, or a video URL.