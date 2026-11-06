# Automated tests

The standard test suite is run from the project root:

```bash
flutter pub get
flutter test
```

Current unit and widget tests cover:

- Incident serialization and compatibility with older photo fields.
- Required-field, email-domain, and password validation.
- IncidentProvider stream behavior using a fake repository.
- Rendering the incident title and status in an incident card.

The device-level smoke test is in `integration_test/app_workflow_test.dart`. It requires generated Firebase options and an Android emulator or physical device:

```bash
flutter test integration_test/app_workflow_test.dart
```

Firebase emulator security tests are a recommended next addition. No test result should be reported as passing until the command has actually been run.
