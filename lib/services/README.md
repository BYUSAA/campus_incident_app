# Firebase service layer

Services encapsulate Firebase SDK calls so screens and providers do not depend directly on SDK implementation details.

| Service | Responsibility |
| --- | --- |
| `FirebaseAuthService` | Create accounts, sign in, auth-state stream, verification email, reload, and sign out |
| `EmailVerificationService` | Send verification emails and refresh verification state |
| `FirestoreService` | User-profile reads/writes and incident collection/document operations |
| `StorageService` | Validate/upload incident photos and delete Storage objects by URL |

## Firebase configuration

The app initializes with `lib/firebase_options.dart`. Run `flutterfire configure --platforms=android` from the project root to generate options for the Firebase project used for testing.

Never hard-code Firebase Admin SDK credentials, service-account JSON, or private keys in Flutter client code.

## Service guidelines

- Inject Firebase SDK objects in constructors when practical for testability.
- Keep Storage paths aligned with deployed Storage rules.
- Use server timestamps for backend creation/update times.
- Return explicit results/errors rather than silently swallowing failures.
- Update security rules whenever collection fields or access patterns change.
