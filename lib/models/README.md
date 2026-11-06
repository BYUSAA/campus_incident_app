# Data models

This folder contains Dart objects used by the UI and Firebase data layer.

## AppUser

Represents `users/{uid}` and stores:
- `uid`: Firebase Authentication UID.
- `name`: profile/display name.
- `email`: ALU email address.
- `role`: `student` or trusted-admin-assigned `staff`.

## Incident

Represents `incidents/{incidentId}` and stores title, description, category, location, status, creator UID, reporter name, optional image URL(s), optional assignee, and creation time.

The model safely maps Firestore `Timestamp` values and tolerates optional/missing fields. It supports both the `imageUrl` field and older/current `photoUrls` arrays.

## Model conventions

- Use explicit Dart types.
- Keep Firestore conversion in `toMap` and `fromMap`.
- Handle missing optional fields safely.
- Add/update tests when a serialized field changes.
- Keep model keys aligned with `firebase/firestore.rules` and the technical report.
