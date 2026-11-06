# Application assets

This folder stores static files bundled with the Flutter application.

## Subfolders

- `images/`: application-owned logos, illustrations, or other static images.
- `icons/`: custom icon assets not already available through Material Icons.
- `fonts/`: fonts the project is licensed to redistribute, with licenses/attributions where required.

## Adding an asset

1. Add only a resource that is used by the application.
2. Confirm the license allows the intended use and redistribution.
3. Declare the asset under the root `flutter:` section in `pubspec.yaml`.
4. Reference it using `Image.asset`, `AssetImage`, or the registered font family.
5. Run `flutter pub get` and test on Android.

Incident evidence photos chosen by users are not bundled here; they are uploaded to Firebase Storage at runtime.
