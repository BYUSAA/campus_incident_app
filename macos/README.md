# macOS desktop platform notes

macOS desktop is optional. A Mac with Xcode is required to generate and build the native macOS runner.

## Generate macOS runner files

From the repository root on a Mac:

```bash
flutter doctor
flutter create --platforms=macos .
flutterfire configure --platforms=macos
flutter pub get
flutter run -d macos
```

Register the macOS application using the correct bundle identifier in Firebase Console. Test Firebase Authentication, Firestore, and file selection in the actual macOS environment.

Keep Apple signing identities, certificates, provisioning profiles, and private keys out of source control. macOS desktop testing does not replace the Android mobile demonstration.
