# Campus Incident Reporter — Technical Report

**Assignment:** Individual Assignment 2 — Campus Incident Reporting App  
**Platform:** Flutter for Android  
**Backend:** Firebase Authentication, Cloud Firestore, and Firebase Storage  
**State management:** Provider with ChangeNotifier  
**Citation style:** IEEE

> **Submission status:** This is an implementation-based report draft. Project-specific Firebase configuration, generated Android runner files, live Firebase evidence, real-device test results, screenshots, and the required 7–10 minute demonstration URL must be added by the student after running the app. No credentials, test outcomes, screenshots, or demo links are invented. Export the completed report as PDF before uploading it to Canvas.

## Abstract

Campus Incident Reporter is a mobile application intended to improve how students communicate campus maintenance and safety issues to authorized staff. Students can register with an ALU student email address, verify their email, submit an incident with a category, description, location, and optional photograph, then follow the report status. Authorized staff can review the incident queue and update report status. The project uses Flutter for the mobile interface and Firebase services for authentication, persistent data, and image storage. Provider separates shared application state from presentation widgets.

## 1. Introduction

Campus facilities issues such as water interruptions, electrical faults, damaged classroom equipment, sanitation problems, and safety concerns can affect students' ability to learn and work. A structured reporting channel helps capture the issue, its location, and enough context for follow-up.

The application was developed with Flutter, a framework for building mobile interfaces from a shared widget system [1]. Firebase provides the backend services used for sign-in, report persistence, and optional image uploads [2]. The main objectives are to collect consistent incident information, associate each report with its creator, let users follow a clear status lifecycle, allow authorized staff to review and process reports, and enforce access rules in the backend rather than relying only on hidden interface controls.

## 2. Users and functional scope

### 2.1 Student

A student account is created with an @alustudent.com email address. The student must verify the email before accessing incident functionality. Students can submit incidents, attach an optional photograph, view and search their own reports, filter by status, inspect report details, and edit or delete their own reports while the status remains **Submitted**. They can replace or remove an attached photograph while editing, update their display name, reset a forgotten password, and save a light/dark appearance preference on the device.

The student feed is intentionally limited to the signed-in student's reports. This is a privacy decision: the application does not expose other students' submissions to every student account.

### 2.2 Authorized staff

Staff use a separate verified ALU account. A trusted Firebase administrator must assign the staff role in the corresponding users/{uid} document. Staff can view the campus incident queue, inspect report details, progress a report from **Submitted** to **In Progress** and then **Resolved**, and delete reports with best-effort photo cleanup.

There is no in-app role switch. A student cannot grant themselves staff access through the client.

## 3. Technical architecture

The codebase separates presentation, state, application workflows, Firebase access, and data models. This separation reduces direct Firebase calls from screens and makes the main workflows easier to maintain.

| Layer | Project location | Responsibility |
| --- | --- | --- |
| Presentation | lib/features/, lib/shared/ | Screens, forms, report cards, navigation |
| State management | lib/providers/ | Authentication, incident streams, theme state |
| Application workflows | lib/repositories/ | Registration, profile loading, incident operations |
| Firebase adapters | lib/services/ | Firebase Authentication, Firestore, Storage |
| Data models | lib/models/ | Typed user and incident data |
| Cross-cutting concerns | lib/core/ | Routing, constants, validation, errors, themes |

### 3.1 Authentication data flow

The registration screen calls AuthProvider, which delegates to AuthRepository. The repository creates a Firebase Authentication account, writes a student profile through UserRepository, and sends the verification email. The authentication provider listens for Firebase Auth state changes and loads the user's application profile.

### 3.2 Incident submission data flow

The incident form validates its title, description, category, and location before calling IncidentProvider. The provider delegates the operation to IncidentRepository. If a photograph is attached, StorageService uploads it to Firebase Storage. The repository then writes the report metadata to Cloud Firestore through FirestoreService. Firestore snapshot streams are mapped to Incident objects and delivered to the listening screens.

### 3.3 Architecture diagram

The editable architecture diagram is stored at docs/architecture/architecture_diagram.mmd. It shows the relationship between Flutter screens, Provider, repositories, Firebase services, and the backend data products.

## 4. Firebase data design

### 4.1 User profile: users/{uid}

| Field | Type | Description |
| --- | --- | --- |
| uid | string | Firebase Authentication user ID |
| name | string | Display name |
| email | string | ALU student email |
| role | string | student by default; staff by trusted administrator assignment |
| emailVerified | boolean | Profile metadata; the Firebase Auth token is authoritative for access |
| createdAt | timestamp | Server creation time |

### 4.2 Incident: incidents/{incidentId}

| Field | Type | Description |
| --- | --- | --- |
| title | string | Short issue summary; maximum 100 characters |
| description | string | Issue details; maximum 1,000 characters |
| category | string | Facilities, Water, Electricity, Safety, or Sanitation |
| location | string | Campus location; maximum 160 characters |
| reportedBy | string | Creator UID |
| reporterName | string | Creator's display name at submission |
| status | string | Submitted, In Progress, or Resolved |
| createdAt | timestamp | Creation time |
| updatedAt | timestamp | Last update time |
| imageUrl | string or null | Optional uploaded image URL |
| photoUrls | string array | Image URL list for compatibility and future extension |
| assignedTo | string or null | Optional staff assignment |

The incident model supports imageUrl and older records containing a photoUrls array. Cloud Firestore stores the user profiles and incident documents, while a composite index supports the student query that filters on reportedBy and sorts by createdAt descending [4].

## 5. Authentication, roles, and security

Firebase Authentication is used for email/password registration and sign-in [3]. Registration validates the ALU email domain, creates the account with a student role, and sends a verification message. The login workflow refreshes the Firebase user and rejects accounts whose email is not verified.

The router directs signed-out users to Login, unverified users to email verification, and verified staff users to the staff dashboard. These route guards, implemented with go_router [8], improve navigation, but they are not the security boundary. Firestore and Storage security rules enforce authorization on backend requests [5], [6].

### 5.1 Firestore authorization

The rules enforce the following behavior:

- Incident operations require a verified @alustudent.com account.
- Users can read only their own profile document; staff role checks use server-side rule lookups rather than granting access to all student profiles.
- Students can read only incidents whose reportedBy value matches their UID.
- Staff can read the incident queue when the trusted profile has the staff role.
- Students can create reports only for themselves and only with initial status Submitted.
- The backend validates required report content, permitted categories, and the same text length limits used by the form.
- Students can edit or delete their own report only while the stored status is still Submitted. They cannot change ownership, reporter identity, creation time, or status.
- Staff updates are limited to status, assignment, and update timestamp. Status progression is forward-only: Submitted to In Progress to Resolved.
- Users cannot change their own role or verification metadata.

### 5.2 Storage authorization

Incident photographs are stored under incident_photos/{uid}/{fileName}. The rules restrict upload and update to the signed-in owner, require supported image content types, and enforce a file size greater than zero and below 8 MB. The owner and authorized staff can read the image; staff may also delete photo evidence when moderating a report. Storage rules are separate from the Flutter interface and must be deployed to the same Firebase project as the Firestore staff-role documents. The rules use Firebase's cross-service Firestore lookup feature; the project administrator must approve the required Storage-to-Firestore permission when prompted. Such lookups consume Firestore document access and are restricted by the Storage Rules access-call limit [10].

### 5.3 Administrative setup

A Firebase administrator must deploy the checked-in rules and indexes to the correct project. The administrator must also assign the staff role to a separate test account. A role value in a local mock or an interface setting is not evidence of backend authorization.

## 6. State management

The project uses Provider with ChangeNotifier, a supported approach for exposing application state to Flutter widgets [7].

- AuthProvider exposes the Firebase user, application profile, loading state, and authentication initialization state. It listens for authentication changes, safely handles asynchronous profile loading, supports password reset, and allows a user to update their display name without changing protected account fields.
- IncidentProvider manages a Firestore stream subscription for the current student's reports or the staff incident queue. It exposes the current list, loading state, and error state, clears stale data when the account/feed changes, and cancels the previous subscription when switching streams or disposing.
- ThemeProvider restores and persists the light/dark appearance preference with local device storage; the system theme is used when no preference is saved.

The separation between screen widgets and repositories keeps the Firebase query and persistence details outside the UI layer.

## 7. UI/UX decisions

The interface focuses on the main user journey: authenticate, report an incident, find a report, inspect its details, and follow its status. The home screen presents a prominent reporting action, a summary of the user's report statuses, and recent reports. The report form uses category selection, required text fields, a campus location, and an optional image picker. Report cards make the title, location, creation date, and status visible. The details screen presents the description, attached image when available, and status progress.

The form and backend use matching length constraints: 100 characters for the title, 1,000 for the description, and 160 for the location. This reduces avoidable rejected writes and protects the data model from oversized input.

**Insert genuine screenshots from the configured Android application before exporting the final PDF.**

| Evidence | Suggested file |
| --- | --- |
| Login screen | docs/screenshots/login.png |
| Registration screen | docs/screenshots/register.png |
| Email verification screen | docs/screenshots/verify_email.png |
| Home dashboard | docs/screenshots/home.png |
| Incident form and selected image | docs/screenshots/create_incident.png |
| Student report list and filters | docs/screenshots/my_incidents.png |
| Incident details and status progress | docs/screenshots/incident_details.png |
| Staff incident queue | docs/screenshots/staff_dashboard.png |
| Staff status update | docs/screenshots/manage_incident.png |
| Firebase Authentication, Firestore, and Storage records | docs/screenshots/firebase_records.png |

Use images from the real app and the student's Firebase project only. Hide email addresses, UIDs, credentials, and private project information.

## 8. Testing strategy and evidence

The repository contains unit and widget tests for incident model mapping, email/name/report validation, forward-only status transitions, Provider feed switching and report actions using a fake repository, incident form required fields, existing-photo removal, and theme preference restoration/persistence. A Firebase Emulator Suite test package verifies Firestore and Storage permissions independently of the UI. An Android integration smoke test is included for the signed-out navigation path. That integration test initializes Firebase and therefore requires real project options and an Android target.

Run these commands from the project root after Android and Firebase configuration:

    flutter pub get
    dart format lib test integration_test
    flutter analyze
    flutter test
    flutter build apk --debug

### 8.1 Verification record

The table below must be completed with actual results from the student's computer. A repository file or planned test is not proof that a command has passed.

| Check | Current evidence status | Student action |
| --- | --- | --- |
| Dependency installation | Not verified in this review | Run flutter pub get |
| Dart formatting | Not verified in this review | Run formatter and inspect the diff |
| Static analysis | Latest GitHub Actions run on the default branch was marked failed | Inspect workflow failure and rerun after fixes |
| Unit/widget tests | Not verified in this review | Run flutter test and record the result |
| Android debug build | Blocked until native Android runner files are generated | Run tooling/bootstrap-android.ps1, then build |
| Firebase student workflow | Not verified against a live Firebase project | Register, verify, sign in, and submit a test report |
| Photo upload | Not verified against a live Storage bucket | Upload and display a real test photo |
| Staff workflow | Not verified against a staff account | Assign a staff role using Firebase administration and update a report |
| Screenshots and video | Not yet present in the repository | Capture genuine evidence and record the 7–10 minute demo |

### 8.2 Test limitations

The automated tests do not replace testing against the student's configured Firebase project. The Firebase Emulator Suite tests cover profile privacy and protected fields, report ownership and lifecycle, status progression, role self-promotion, staff deletion, and Storage ownership/type/size restrictions.

## 9. Challenges and design trade-offs

The main setup dependency is the use of project-specific Firebase configuration. It is not safe to invent Firebase app IDs, API keys, or sender IDs, so the repository keeps a fail-fast placeholder until FlutterFire generates options for the actual project. The Android runner also needs to be generated with the installed Flutter SDK. FlutterFire plugins are aligned to the official Flutter BoM 4.20.2 release set. The Android minimum SDK is set to API 24 because the selected `image_picker` 1.2.4 release supports Android API 24 and newer. The bootstrap script explicitly sets Android `minSdk` to API 24, matching the current Firebase Android SDK requirement [11]. Windows scripts in the `tooling/` directory automate these steps and require the developer to select the actual Firebase project. The deployment script asks for explicit confirmation before publishing rules.

The application uses student-owned report queries to protect student privacy. Staff access is role-based and depends on a trusted administrator action. The current search and status filtering operate on the data currently loaded into the client; pagination and server-side filtering would be important for a larger deployment. Push notifications, offline submission, and a full assignment/dispatch workflow are not implemented.

## 10. Lessons learned and future work

The project demonstrates why client-side navigation checks and backend authorization must be treated separately. Provider stream subscriptions help keep screens in sync with Firestore changes, while repositories and service classes isolate persistence from presentation. Form validation should match backend constraints so that accepted UI input is also accepted by Firestore rules.

The repository includes Firebase Emulator Suite security tests for profile privacy and field protection, student ownership, role self-promotion, email verification, report lifecycle, status progression, staff deletion, and photo access. Further improvements include paginated incident feeds, notifications when report status changes, and a trusted staff assignment interface.

## 11. Project repository and demonstration video

**GitHub repository:** https://github.com/BYUSAA/campus_incident_app

**Video URL:** Add the accessible URL for the genuine 7–10 minute Android demonstration before submission.

The recording must show student registration and verification, login, incident creation with an optional photo, browsing/search/filtering, report details, and a separate authorized staff account updating a report status. It should also show relevant Firebase Console records and explain the architecture. Use docs/demo_script.md. Do not show passwords, private keys, or personal information.

## References

[1] Google, “Flutter documentation.” [Online]. Available: https://docs.flutter.dev/. [Accessed: Nov. 7, 2026].

[2] Google, “Add Firebase to your Flutter app.” [Online]. Available: https://firebase.google.com/docs/flutter/setup. [Accessed: Nov. 7, 2026].

[3] Google, “Get started with Firebase Authentication on Flutter.” [Online]. Available: https://firebase.google.com/docs/auth/flutter/start. [Accessed: Nov. 7, 2026].

[4] Google, “Cloud Firestore documentation.” [Online]. Available: https://firebase.google.com/docs/firestore. [Accessed: Nov. 7, 2026].

[5] Google, “Get started with Cloud Firestore Security Rules.” [Online]. Available: https://firebase.google.com/docs/firestore/security/get-started. [Accessed: Nov. 7, 2026].

[6] Google, “Get started with Cloud Storage Security Rules.” [Online]. Available: https://firebase.google.com/docs/storage/security. [Accessed: Nov. 7, 2026].

[7] “provider: A wrapper around InheritedWidget to make them easier to use and more reusable,” pub.dev. [Online]. Available: https://pub.dev/packages/provider. [Accessed: Nov. 7, 2026].

[8] “go_router: A declarative router for Flutter,” pub.dev. [Online]. Available: https://pub.dev/packages/go_router. [Accessed: Nov. 7, 2026].

[9] Google, “Build unit tests for Firebase Security Rules.” [Online]. Available: https://firebase.google.com/docs/rules/unit-tests. [Accessed: Nov. 7, 2026].

[10] Google, “Use conditions in Cloud Storage Security Rules.” [Online]. Available: https://firebase.google.com/docs/storage/security/rules-conditions. [Accessed: Nov. 7, 2026].

[11] Google, “Add Firebase to your Android project.” [Online]. Available: https://firebase.google.com/docs/android/setup. [Accessed: Nov. 7, 2026].
