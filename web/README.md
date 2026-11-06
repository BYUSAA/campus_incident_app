# Web platform notes

Web is an optional target. It is not a substitute for the Android mobile workflow.

## Generate and configure web support

From the repository root:

```bash
flutter create --platforms=web .
flutterfire configure --platforms=web
flutter pub get
flutter run -d chrome
```

Register the web app with the Firebase project and confirm Authentication, Firestore, and Storage configuration.

## Browser verification

- Verify sign-in and email verification redirects.
- Check Firestore rules using separate student and staff test accounts.
- Test browser file selection and image upload.
- Confirm Firebase Authentication authorized domains include the browser domain used for testing.
- Never place Admin SDK credentials or private keys in client code.

A browser demonstration does not verify Android camera/gallery behavior, Android permissions, or the APK build. Final evidence should include the Android target.
