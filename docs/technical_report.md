# Campus Incident Reporter — Technical Report

> **Submission evidence note:** This report describes the repository implementation and its design. Device screenshots, Firebase Console evidence, observed test results, and the demo-video link must be added after the application has been configured and run. No results or evidence are invented here.

## 1. Introduction

Campus incidents such as damaged facilities, sanitation problems, water interruptions, electrical faults, and safety concerns need a clear way to be reported and followed up. Campus Incident Reporter is a Flutter mobile application backed by Firebase. It gives students a structured way to submit an incident and check its status. Authorized staff can review reports and update their progress.

The main objectives are to collect consistent report information, keep reports associated with their creator, provide a simple status lifecycle, and apply access control in Firebase rather than relying only on what the interface displays.

## 2. Users and functional scope

### Student

A student can create an account with an `@alustudent.com` address, verify the address, sign in, submit a report, attach an optional image, search and filter their reports, view report details, edit a report while it is still Submitted, and delete their own report.

### Staff

A staff member uses a separate account that has been assigned the `staff` role through a trusted Firebase administrator process. Staff can view the incident queue and update report status to Submitted, In Progress, or Resolved. Regular users cannot promote themselves to staff.

## 3. Technical architecture

The project separates responsibilities so that screens do not call Firebase directly:

- **Features and shared widgets:** presentation and user interaction.
- **Providers:** application state and Firestore stream subscriptions.
- **Repositories:** use-case coordination and data mapping.
- **Services:** Firebase Authentication, Cloud Firestore, Firebase Storage, and verification email calls.
- **Models:** typed user and incident data.

See [the architecture explanation](architecture/README.md) and [Mermaid diagram](architecture/architecture_diagram.mmd).

### Main data flow

For registration, the screen calls `AuthProvider`, which delegates to `AuthRepository`. The repository creates the Firebase Authentication account, writes a student profile through `UserRepository`, and sends a verification email.

For an incident, `IncidentForm` calls `IncidentProvider`. `IncidentRepository` optionally uploads a photo through `StorageService`, then creates or updates the incident through `FirestoreService`. Snapshot streams return mapped `Incident` objects to the provider and listening screens.

## 4. Firebase data structure

### User profile: `users/{uid}`

| Field | Type | Description |
| --- | --- | --- |
| `uid` | string | Firebase Authentication user ID |
| `name` | string | User's display name |
| `email` | string | ALU student email |
| `role` | string | `student` by default; `staff` by trusted administrator assignment |
| `emailVerified` | boolean | Profile metadata; Firebase Auth token is authoritative for access |
| `createdAt` | timestamp | Server creation time |

### Incident: `incidents/{incidentId}`

| Field | Type | Description |
| --- | --- | --- |
| `title` | string | Short summary |
| `description` | string | Details of the issue |
| `category` | string | Facilities, Water, Electricity, Safety, or Sanitation |
| `location` | string | Campus location |
| `reportedBy` | string | Creator UID |
| `reporterName` | string | Creator display name at submission |
| `status` | string | Submitted, In Progress, or Resolved |
| `createdAt` | timestamp | Server creation time |
| `updatedAt` | timestamp | Last update time |
| `imageUrl` | string or null | Optional uploaded image URL |
| `photoUrls` | string array | Image URL list for compatibility/future extension |
| `assignedTo` | string or null | Optional staff assignment |

The model reads both the current `imageUrl` value and earlier documents that store the first photo in `photoUrls`.

## 5. Authentication and authorization

Registration validates the ALU student email domain and creates a Firebase Authentication account. The user profile is created with the `student` role, and a verification email is sent. Login reloads the Firebase user and rejects an account that has not verified its email. The application restores authentication state from Firebase and provides a verification screen with resend and re-check actions.

The router sends signed-out users to Login, unverified accounts to the verification screen, and verified staff accounts to the staff dashboard. This improves the user experience but is not the security boundary.

The Firestore rules enforce:

- A valid ALU email domain and verified email for incident operations.
- Student reads only for documents where `reportedBy` equals the signed-in UID.
- Staff reads across the incident collection when the user's Firestore profile has the trusted `staff` role.
- Student creation with their own UID and initial `Submitted` status.
- Student content edits without changing ownership, creation time, or status.
- Staff updates limited to status, assignment, and update timestamp.
- No self-service role promotion.

Storage rules scope files to `incident_photos/{uid}/{fileName}`, validate image content type and an 8 MB size limit, and restrict access to the owner or authorized staff.

A project administrator must deploy the rules and indexes using the Firebase CLI. Rules in source control are not active until deployed to the correct Firebase project.

## 6. State management

`AuthProvider` exposes the current Firebase user, application profile, loading state, and authentication initialization state. It listens to Firebase Authentication state changes and notifies the router and screens.

`IncidentProvider` manages a Firestore stream subscription for the current student's reports or the staff incident queue. It cancels the previous subscription when switching datasets and when disposed. The provider exposes loading and error states as well as the latest incident list.

`ThemeProvider` manages the current light/dark appearance selection for the running app session.

## 7. User interface and usability

The interface is organized around a small number of tasks: authenticate, submit a report, find an existing report, inspect its details, and manage its status. Input validation is applied to required fields. Photo upload is optional so a report can still be submitted when an image is unavailable. Search covers title, description, category, and location; status filters support follow-up.

**Screenshots to add after running the app:**

| Evidence | File to add |
| --- | --- |
| Login screen | `docs/screenshots/login.png` |
| Registration screen | `docs/screenshots/register.png` |
| Email verification screen | `docs/screenshots/verify_email.png` |
| Home dashboard | `docs/screenshots/home.png` |
| New incident form with photo selected | `docs/screenshots/create_incident.png` |
| Student incident list and filters | `docs/screenshots/my_incidents.png` |
| Incident details | `docs/screenshots/incident_details.png` |
| Staff incident queue | `docs/screenshots/staff_dashboard.png` |
| Staff status management | `docs/screenshots/manage_incident.png` |
| Firestore/Storage evidence with private values obscured | `docs/screenshots/firebase_records.png` |

Only include images from the actual running application and your own Firebase project. Obscure email addresses, user IDs, and any personal or sensitive information.

## 8. Testing and verification

Run the following commands from the repository root after generating Android scaffolding and Firebase configuration:

```bash
flutter pub get
dart format lib test integration_test
flutter analyze
flutter test
flutter build apk --debug
```

The unit and widget tests cover model mapping, input validation, provider stream handling with a fake repository, and incident-card rendering. The device integration smoke test requires a configured Firebase project and an Android device/emulator.

**Actual verification record — complete after running locally:**

| Check | Result | Environment / notes |
| --- | --- | --- |
| `flutter pub get` | Not yet recorded | Add date and Flutter version |
| `dart format` | Not yet recorded | Add any formatting changes |
| `flutter analyze` | Not yet recorded | Paste actual result |
| `flutter test` | Not yet recorded | Paste actual test count |
| `flutter build apk --debug` | Not yet recorded | Add Android SDK/device details |
| Firebase student workflow | Not yet recorded | Test with verified ALU account |
| Firebase staff workflow | Not yet recorded | Test with admin-assigned staff account |

Do not replace these entries with a passing result until the command or workflow has actually completed.

## 9. Known setup dependencies and limitations

- The generated Firebase configuration is project-specific. `lib/firebase_options.dart` remains a fail-fast setup placeholder until `flutterfire configure --platforms=android` is run.
- The Android runner files must be generated using the local Flutter SDK because the Android directory currently contains setup guidance only.
- The staff role must be assigned by an administrator in Firebase Console or through a trusted Admin SDK process.
- Search and status filtering are performed on the currently loaded list. Large deployments may need server-side pagination and additional composite indexes.
- The current implementation supports an optional incident photo. It does not include push notifications, offline report submission, or a production staff-assignment workflow.
- The appearance preference currently applies for the active app session; it is not persisted between restarts.

## 10. Lessons and next improvements

The architecture keeps Firebase operations outside the presentation widgets and centralizes access control in Firebase rules. The most important next improvements are automated Firestore/Storage emulator security tests, pagination for large incident queues, notification of status changes, and an administrator-managed staff assignment workflow.

## 11. Demo video

**Video link:** Add the accessible link after recording the real 7–10 minute Android demonstration.

Use [the demo script](demo_script.md) to show both student and staff workflows. The video should be recorded after Firebase configuration, rule deployment, and local verification.

## References

- Flutter documentation: https://docs.flutter.dev/
- Firebase for Flutter: https://firebase.google.com/docs/flutter/setup
- Firebase Authentication: https://firebase.google.com/docs/auth/flutter/start
- Cloud Firestore: https://firebase.google.com/docs/firestore
- Firestore security rules: https://firebase.google.com/docs/firestore/security/get-started
- Cloud Storage security rules: https://firebase.google.com/docs/storage/security
- Provider package: https://pub.dev/packages/provider
- go_router package: https://pub.dev/packages/go_router
