# Provider state management

This folder contains application-wide state classes implemented with Flutter `ChangeNotifier` and Provider.

## AuthProvider

- Observes Firebase Authentication state through `AuthRepository`.
- Exposes Firebase user and application profile.
- Tracks initialization and loading/error state.
- Supports registration, sign-in, email-verification refresh/resend, profile refresh, and logout.
- Notifies screens and the router when session state changes.

## IncidentProvider

- Subscribes to either the signed-in student's incident stream or the staff incident stream.
- Exposes current reports, loading state, and error messages.
- Delegates create, edit, delete, and status changes to `IncidentRepository`.
- Cancels its previous stream subscription when switching streams and when disposed.

## ThemeProvider

- Exposes the selected `ThemeMode`.
- Notifies the app when light/dark mode changes.
- The current selection is held in memory and is not persisted between launches.

## Guidelines

Keep Firebase SDK details out of providers, make state transitions predictable, cancel stream subscriptions, and inject repositories in tests to avoid live Firebase calls.
