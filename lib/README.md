# Flutter application source

The `lib/` directory contains the Flutter application.

## Structure

- `main.dart`: initializes Flutter/Firebase, registers global providers, and starts the app.
- `app.dart`: configures MaterialApp, routing, and themes.
- `features/`: user-facing flows grouped by product feature.
- `models/`: user and incident data models.
- `providers/`: shared application state.
- `repositories/`: application workflows and data mapping.
- `services/`: Firebase SDK integrations.
- `core/`: routing, constants, validation, errors, theme, and utilities.
- `shared/`: reusable widgets and navigation layout.
- `firebase_options.dart`: FlutterFire-generated project configuration; it must be generated locally.

## Development conventions

- Keep Firebase SDK calls in services/repositories, not directly in screen widgets.
- Put shared app state in providers and short-lived form state in widgets.
- Validate form data before saving.
- Show loading and error feedback for asynchronous operations.
- Keep backend authorization in Firebase security rules, not only in UI/route logic.
- Run `dart format`, `flutter analyze`, and `flutter test` after code changes.

The Firebase options file is a fail-fast placeholder until generated for the developer's Firebase project.
