# Repository layer

Repositories coordinate application workflows and isolate screens/providers from Firebase SDK details.

## AuthRepository

Coordinates ALU email validation, Firebase account creation, student profile creation/loading, email verification, verified sign-in, password reset, display-name updates, and logout.

## UserRepository

Creates and reads user profile documents in `users/{uid}` through `FirestoreService`.

## IncidentRepository

Coordinates:
- Real-time streams for all incidents and one user's incidents.
- Incident creation and optional image upload.
- Incident lookup and content updates.
- Status updates to supported lifecycle values.
- Report deletion and best-effort cleanup of associated Storage images.
- Photo replacement and removal while editing a submitted report.

## Change guidelines

- Keep Firestore query/mapping behavior at the repository/service boundary.
- Keep collection fields synchronized with `firebase/firestore.rules`.
- Keep Storage paths synchronized with `firebase/storage.rules`.
- Update tests when document fields or query behavior changes.
- Never add client-side self-promotion to staff.
