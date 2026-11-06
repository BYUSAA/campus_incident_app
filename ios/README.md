# iOS platform notes

iOS is an optional Flutter target. Android remains the intended platform for the assignment demonstration.

## Current state

Shared Flutter code includes Firebase and image-picker integrations. Generated iOS Runner/Xcode project files are not committed. iOS development requires macOS, Xcode, and the appropriate CocoaPods setup.

## Generate iOS files

On a Mac, from the project root:

```bash
flutter doctor
flutter create --platforms=ios .
```

Register the generated bundle identifier with Firebase Console. Enable the Firebase products required by the app and configure:

```bash
flutterfire configure --platforms=ios
flutter pub get
flutter run
```

## Platform verification

- Test email/password registration, verification, and sign-in.
- Test gallery selection and camera access on a physical iPhone.
- Review photo-library and camera permission descriptions in the generated `Info.plist`.
- Confirm Firebase options include the iOS configuration if iOS is used.

Do not commit Apple signing certificates, provisioning profiles, distribution keys, or private signing material. iOS testing does not replace the required Android evidence.
