# Firebase backend configuration

This folder stores Firebase security and query configuration for Campus Incident Reporter. These files must be deployed to the Firebase project selected by the developer; committing rules does not automatically protect a live project.

## Files

| File | Purpose |
| --- | --- |
| `firestore.rules` | Verified ALU accounts, user profiles, report ownership, and staff moderation |
| `storage.rules` | Image upload path, size/content checks, and owner/staff access |
| `firestore.indexes.json` | Composite index for a user's incidents ordered by creation time |
| Root `firebase.json` | Maps Firebase CLI deployment to these files |

## Firebase products

- **Authentication:** email/password accounts and verification.
- **Cloud Firestore:** profile documents at `users/{uid}` and reports at `incidents/{incidentId}`.
- **Cloud Storage:** optional images at `incident_photos/{uid}/{fileName}`.

## Access-control model

### Profiles

New profiles are created with the `student` role. A user may update permitted profile fields, but cannot change their own role or email field. Staff role promotion must be performed by a trusted project administrator using a controlled administrative process.

### Incidents

- Operations require a verified `@alustudent.com` user.
- Students can read reports they own, based on `reportedBy`.
- Staff can read the full incident queue when the trusted profile role is `staff`.
- Students create reports only for themselves and only with initial status `Submitted`.
- Student updates are restricted to report content and photo fields; owner, creation time, and status are protected.
- Staff updates are limited to status, assignment, and update timestamp.
- Students may delete their own reports; staff may moderate reports.

### Storage

Images are stored under `incident_photos/{uid}/`. Rules restrict creation/update to the signed-in owner, supported image MIME types, and a file size below 8 MB. Staff may read images attached to reports.

## Configure and deploy

Install Firebase CLI, authenticate, and select the Firebase project associated with the generated FlutterFire configuration:

```powershell
firebase login
firebase use --add
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Confirm the selected project before deployment. Never deploy sample/course rules to a production project containing unrelated user data without review.

## Query and index relationship

The student incident feed filters by `reportedBy` and sorts by `createdAt` descending. The composite index for that query is defined in `firestore.indexes.json`.

Firestore rules are not query filters. Student queries must include the ownership condition so every possible returned document is authorized.

## Before using real data

- Review rule logic and deploy it to the intended Firebase project.
- Test access with at least two separate student accounts.
- Confirm one student cannot read or change another student's report.
- Confirm a student cannot promote themselves to staff.
- Confirm staff can review reports and only update allowed moderation fields.
- Confirm Storage rejects oversized files and non-image content.
- Add Firebase Emulator Suite security tests before production use.

Never commit Firebase Admin SDK credentials, service-account JSON, or private keys into this folder or Flutter client code.


## Validation enforced by the current rules

Incident titles are limited to 100 characters, descriptions to 1,000 characters, locations to 160 characters, and categories to Facilities, Water, Electricity, Safety, or Sanitation. These checks run in Firestore rules as well as in the Flutter form. A student can edit report content only while the stored status is still Submitted; changing the client UI or calling Firestore directly does not bypass this backend condition.
