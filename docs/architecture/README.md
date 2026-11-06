# Application architecture

Campus Incident Reporter separates presentation, state, application workflows, and Firebase access. Screens should not call Firebase SDKs directly; each layer has a focused responsibility.

## Layers

| Layer | Location | Responsibility |
| --- | --- | --- |
| Presentation | `lib/features/`, `lib/shared/` | Screens, forms, report cards, navigation |
| State | `lib/providers/` | ChangeNotifier state, loading/error state, stream lifecycle |
| Application workflows | `lib/repositories/` | Registration, profile loading, incident creation/editing/deletion |
| Data services | `lib/services/` | Firebase Authentication, Firestore, Storage |
| Data models | `lib/models/` | User and incident data objects |
| Cross-cutting | `lib/core/` | Routing, constants, validation, errors, themes |

## Registration and sign-in

```text
RegisterScreen / LoginScreen
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

The authentication provider observes Firebase Auth state. The router waits for initial session/profile loading before routing a user to Login, email verification, student pages, or staff pages.

## Incident submission with an optional photo

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

The image is uploaded under `incident_photos/{uid}/`. The image URL and report metadata are saved to the incident document.

## Live updates and staff moderation

Firestore snapshot streams are mapped to `Incident` objects by the repository. The provider subscribes, notifies the UI when data changes, and cancels its subscription when the selected stream changes or the provider is disposed.

The router uses the loaded user profile role to protect staff navigation. Firestore and Storage rules independently verify the signed-in user's email, role, and report ownership. The route guard is a navigation aid, not the security boundary.

## Diagram source

The editable Mermaid diagram is [architecture_diagram.mmd](architecture_diagram.mmd). GitHub renders Mermaid in Markdown. Export it to PNG or SVG only when an external report format specifically requires an image.

## Design rules

- New accounts are created with the `student` role.
- Staff access must be granted by trusted Firebase administration.
- Firebase Authentication is authoritative for email verification.
- Queries must include ownership constraints required by Firestore rules.
- The incident model reads both `imageUrl` and legacy `photoUrls` records.
- Providers expose loading/error state and manage subscriptions.
