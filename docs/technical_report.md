# Campus Incident Reporting App — Technical Report

> Complete this with your own implementation evidence after Firebase setup. Use APA or IEEE consistently.

## 1. Introduction
Explain the campus problem, target users and objectives.
## 2. Architecture
Explain the separation between `features/`, `shared/`, `providers/`, `models/`, `repositories/` and `services/`. Add a diagram of UI → Provider → Repository → Firebase services.
## 3. Firebase data structure
Document actual `users/{uid}` and `incidents/{incidentId}` fields. Add Firebase Console screenshots with personal data obscured.
## 4. Authentication and access control
Explain email verification, session handling, student role assignment, trusted staff authorization, Firestore Rules and Storage Rules. UI hiding alone is not security.
## 5. State management
Explain Provider and how `AuthProvider`, `IncidentProvider` and `ThemeProvider` update the UI.
## 6. UI/UX decisions
Add screenshots of login, registration, incident creation, list, details and staff management. Justify usability decisions.
## 7. Testing
Record Flutter version, device/emulator, test commands and real outcomes. Do not claim tests passed until you run them.
## 8. Challenges and lessons learned
Describe actual problems encountered and how you addressed them.
## 9. Limitations and future work
Document remaining limitations honestly.
## 10. Demo video
Paste the accessible 7–10 minute demo link and summarize the workflows shown.
## References
Add official Flutter/Firebase and other sources in APA or IEEE format.
