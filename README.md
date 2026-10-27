# Campus Incident Reporting App

Flutter + Firebase starter implementation for campus incident reporting.

## Included
- Email/password registration, login, email verification and logout using Firebase Authentication.
- ALU email-domain validation (`@alustudent.com`).
- Firestore-backed incident reports and Firebase Storage photo uploads.
- Provider state management, incident search/filtering, report details, student/staff UI separation.
- Security rules, tests and report/demo templates.

## Important setup before running
This project cannot connect to your Firebase project until configured. From the project root:

```bash
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
flutter pub get
flutter run
```

`flutterfire configure` generates the real `lib/firebase_options.dart`; replace the setup placeholder in this archive with the generated file. In Firebase Console enable Email/Password Authentication, create Firestore and enable Storage.

New accounts are always students. For staff testing, assign `users/{uid}.role = "staff"` through a trusted admin process. Do not create a client-side self-promotion feature. The Firestore rules restrict role changes by users.

## Run checks
```bash
flutter analyze
flutter test
```

Platform directories are included as placeholders. Run `flutter create .` from the root to generate native platform scaffolding for your installed Flutter version (iOS generation/build requires macOS). The app must be demonstrated on Android or iOS, not only a browser.

Update `docs/technical_report.md`, add real screenshots, replace the architecture diagram placeholder, and record a 7–10 minute demo video after you have run the app. These evidence-based deliverables cannot be completed without your Firebase project and real test results.
