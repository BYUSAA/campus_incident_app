# Firebase Emulator security tests

This package verifies the Firestore and Cloud Storage rules without using the live Firebase project.

## Requirements

- Node.js 22
- Java 17 or later
- Firebase CLI (the repository workflow invokes it through npx)

## Run from the repository root

```powershell
cd firebase/rules-tests
npm install
cd ../..
firebase emulators:exec --project demo-campus-incident-reporter --only firestore,storage "npm --prefix firebase/rules-tests test"
```

The emulator project ID starts with `demo-`; no production Firebase project or service account is used.

## Coverage

The tests cover:
- unverified ALU profile creation and verified account requirements for incidents;
- student report ownership and Firestore query constraints;
- prevention of client-side staff role promotion;
- allowed categories and bounded incident content;
- student edits/deletes while a report is still Submitted;
- staff access to the incident queue and forward-only status transitions;
- image upload ownership and MIME-type validation; and
- staff access to read/delete photos when moderating a report.

Test data is seeded only with emulator rules disabled. All client-context operations are checked against the actual rules from `firebase/firestore.rules` and `firebase/storage.rules`.
