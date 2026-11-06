# Application architecture

The app follows a layered Flutter structure:

1. **Feature screens and shared widgets** render forms, lists, dashboards, and report details.
2. **Providers** expose application state and notify the UI when authentication or incident streams change.
3. **Repositories** coordinate workflows such as registration, profile loading, incident creation, photo upload, editing, and deletion.
4. **Services** isolate Firebase Authentication, Cloud Firestore, Firebase Storage, and verification-email operations.

## Data flow

- Authentication: `LoginScreen/RegisterScreen → AuthProvider → AuthRepository → FirebaseAuthService / UserRepository → Firebase`.
- Incident creation: `IncidentForm → IncidentProvider → IncidentRepository → StorageService (optional photo) → FirestoreService → Cloud Firestore`.
- Live updates: `Firestore snapshots → IncidentRepository → IncidentProvider → listening screens`.
- Staff status updates: Flutter route guard checks the profile role for navigation; Firestore and Storage security rules independently enforce authorization.

## Diagram

The Mermaid source is in [architecture_diagram.mmd](architecture_diagram.mmd). GitHub renders Mermaid in Markdown. For a report that requires an image, export the source to PNG or SVG and place the exported file in this folder.

## Security boundary

A route guard and hidden UI control improve navigation but are not sufficient security. Firebase rules require a verified ALU email, check the user profile role for staff access, restrict student reads to their own reports, and restrict each upload to the owner's Storage directory.
