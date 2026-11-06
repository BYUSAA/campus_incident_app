# Firebase configuration

This folder contains the Firebase backend configuration tracked for the app. It does not include a Firebase project ID or generated client configuration.

## Files

- `firestore.rules`: verified ALU authentication, user-profile ownership, student report ownership, and staff-only moderation rules.
- `storage.rules`: image uploads restricted to `incident_photos/{uid}/`, with owner/staff access and an 8 MB limit.
- `firestore.indexes.json`: composite index for the student's incident query sorted by creation time.
- Root `firebase.json`: connects the Firebase CLI to these rule and index files.

## Configure and deploy

From the repository root:

```bash
firebase login
firebase use --add
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Select the same Firebase project that generated `lib/firebase_options.dart`. A project administrator must assign the `staff` role in `users/{uid}`; normal clients cannot change their role.

After changing any collection field or query, review the Firestore rules and indexes together. Firestore queries must be constrained so every returned document is authorized by the deployed rules.
