# Application architecture

Campus Incident Reporter separates presentation, state, application workflows, Firebase access, and data models. Screens collect input and render state; providers coordinate shared state; repositories coordinate workflows; services isolate Firebase SDK operations.

## Layers

| Layer | Location | Responsibility |
| --- | --- | --- |
| Presentation | `lib/features/`, `lib/shared/` | Screens, forms, reusable widgets, navigation |
| State | `lib/providers/` | ChangeNotifier state, loading/error state, stream lifecycle |
| Application workflows | `lib/repositories/` | Authentication and incident operations |
| Firebase adapters | `lib/services/` | Firebase Authentication, Firestore, Storage |
| Data models | `lib/models/` | Typed user and incident mapping |
| Cross-cutting | `lib/core/` | Routing, constants, validation, errors, themes |

## Authentication and profile loading

```text
Login/Register screens
          |
          v
     AuthProvider
          |
          v
    AuthRepository
       /       \
      v         v
 Firebase Auth  UserRepository
      |              |
      v              v
 Verification   FirestoreService
      |              |
      v              v
 Firebase       users/{uid}
```

The authentication provider listens for Firebase Auth state changes. A monotonically increasing event version prevents an older profile request from restoring a previous user after sign-out or a later Auth event. Registration invalidates the initial account-created event before reloading the created profile. Email verification forces a fresh Firebase ID token so Firestore and Storage rules receive the updated `email_verified` claim. Protected routes remain in the splash state until profile loading completes.

## Incident submission

```text
IncidentForm
    |
    v
IncidentProvider
    |
    v
IncidentRepository
    |                 \
    v                  v
StorageService    FirestoreService
    |                  |
    v                  v
Firebase Storage   Cloud Firestore
```

The optional photo is uploaded under `incident_photos/{uid}/`. Its URL and report metadata are saved in the incident document. Edit forms preview existing photos and support replacing/removing them. If a Firestore create/update fails, the repository attempts to remove the newly uploaded object. After a report is deleted, photo cleanup is attempted and logged separately so a temporary Storage failure does not falsely report that the Firestore deletion itself failed.

## Live updates and staff moderation

Firestore snapshot streams are mapped to `Incident` objects by the repository. The provider subscribes, notifies listening screens when new data arrives, clears prior user data when switching feeds, ignores events from superseded subscriptions, and cancels the active subscription when disposed.

Staff status progression is forward-only: `Submitted` → `In Progress` → `Resolved`. The management screen stays open after a successful update so staff can complete both transitions in one visit. The status control and repository validate transitions for usability; Firestore rules remain the authoritative backend restriction.

Student reads are scoped to report ownership. Student edits and deletes are allowed only while the report remains `Submitted`. Staff access uses the trusted role stored in `users/{uid}`. Firestore and Storage rules enforce authorization independently of the router.

## Diagram source

The editable Mermaid diagram is [architecture_diagram.mmd](architecture_diagram.mmd).

## Design rules

- New accounts are created as `student`.
- Staff access is assigned by trusted Firebase administration only.
- Firebase Auth token claims are authoritative for email verification.
- Student incident queries include the `reportedBy` ownership filter.
- Report field limits match Flutter validation and Firestore rules.
- Photos are stored under the owning user's UID.
- Providers manage subscription lifecycle and ignore stale events.