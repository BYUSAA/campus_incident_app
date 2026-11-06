# Font assets

Store only font files that the project is licensed to redistribute. Add the corresponding license and attribution documents when required.

When adding a custom font:
1. Register the font family and each weight under `fonts:` in the root `pubspec.yaml`.
2. Use the exact registered family name in the Flutter theme.
3. Run `flutter pub get` and check text rendering on Android.

The application currently uses the platform/theme default font. A custom font is not required to run the app.
