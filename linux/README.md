# Linux desktop platform notes

Linux desktop is optional and is not part of the primary Android mobile workflow.

## Generate Linux runner files

On a Linux development machine with Flutter desktop prerequisites installed, run from the project root:

```bash
flutter doctor
flutter create --platforms=linux .
flutter run -d linux
```

Configure Firebase for Linux if that target is needed:

```bash
flutterfire configure --platforms=linux
flutter pub get
```

Check support for Firebase plugins and image selection in the target Linux environment before relying on desktop behavior. A Linux run does not verify Android permissions, camera/gallery behavior, or the Android APK build.
