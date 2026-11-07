# Firebase backend configuration

This folder contains the Firebase rules, Firestore index, and automated emulator tests for Campus Incident Reporter. Configuration in GitHub is not active in a Firebase project until it is deployed.

## Firebase products

- **Authentication:** Email/Password accounts and verification.
- **Cloud Firestore:** user profiles at `users/{uid}` and incident records at `incidents/{incidentId}`.
- **Cloud Storage:** optional photos at `incident_photos/{uid}/{fileName}`.
- **Local Emulator Suite:** isolated Auth, Firestore, and Storage testing without writing to production data.

## Data and access model

Newly registered ALU accounts receive the `student` role. A trusted Firebase administrator assigns the `staff` role to a separate account. The mobile client has no role promotion feature.

| Operation | Student | Authorized staff |
| --- | --- | --- |
| Read incident | Own report only | All reports |
| Create incident | Own report, initial status Submitted | Not exposed in the staff UI |
| Edit report content | Own report while Submitted | No content edit in current UI |
| Change status | Not allowed | Forward only: Submitted → In Progress → Resolved |
| Delete incident | Own report while Submitted | Any report |
| Read attached photo | Own report photos | All incident photos |
| Delete attached photo | Own photo | All incident photos |

Rules enforce verified `@alustudent.com` email addresses for incident and photo operations. Student list queries must include `reportedBy == request.auth.uid`; Firestore rules are not query filters.

## Validation enforced by Firestore

- Title: 1–100 characters.
- Description: 1–1,000 characters.
- Location: 1–160 characters.
- Category: Facilities, Water, Electricity, Safety, or Sanitation.
- New reports start as Submitted.
- Student edits cannot change owner, reporter identity, creation time, or status.
- Report status updates are performed by staff and cannot move backwards in the lifecycle.
- Staff cannot change the report owner or original content through the status-update workflow.

## Configure a Firebase project

1. Create or select the Firebase project.
2. In **Authentication → Sign-in method**, enable **Email/Password**.
3. Create the Cloud Firestore database.
4. Enable the default Cloud Storage bucket.
5. Generate Android project files and record its application ID.
6. Register that Android application ID in Firebase Console.
7. From the repository root, run:

   ```powershell
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure --platforms=android
   ```

8. Select the same Firebase project for the CLI and FlutterFire configuration.
9. Confirm that `lib/firebase_options.dart` was generated for Android.

The generated FlutterFire options file contains project-specific Firebase app identifiers and is required by the client. Never commit Firebase Admin SDK service-account credentials or private keys.

## Deploy rules and indexes

After selecting the project in the Firebase CLI, inspect the active project and deploy:

```powershell
firebase use --add
firebase projects:list
firebase deploy --only firestore:rules,firestore:indexes,storage
```

The CLI's selected project must match the project configured in `lib/firebase_options.dart`. Do not deploy to a production project until you have reviewed the rules and confirmed the target.

## Run security-rule tests locally

Requirements: Node.js 22, Java 17 or later, Firebase CLI, and npm.

```powershell
cd firebase/rules-tests
npm install
cd ../..
firebase emulators:exec --project demo-campus-incident-reporter --only firestore,storage "npm --prefix firebase/rules-tests test"
```

The project ID begins with `demo-`, so tests run against local emulators and do not require a live Firebase project. The test suite checks profile self-promotion, ALU email verification, incident ownership, query restrictions, student edit/delete rules, staff access, status progression, image MIME type, Storage ownership, and staff evidence cleanup.

## Firestore index

The student feed filters by `reportedBy` and orders by `createdAt` descending. Its composite index is in `firestore/firestore.indexes.json` (path relative to the repository root: `firebase/firestore.indexes.json`).

## Before using real data

- Deploy rules and indexes to the intended project.
- Test using two student accounts and one admin-assigned staff account.
- Confirm cross-student access is denied.
- Confirm a student cannot promote themselves or update report status.
- Confirm staff can review reports and progress statuses.
- Confirm only authorized owners/staff can access evidence photos.
- Never place passwords, service account JSON, or private keys in the repository.
