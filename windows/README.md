# Windows desktop platform notes

Windows desktop is optional. Android is the intended target for the project's mobile demonstration.

## Generate Windows runner files

On Windows with the Flutter desktop toolchain installed, run from the repository root:

```powershell
flutter doctor
flutter create --platforms=windows .
flutterfire configure --platforms=windows
flutter pub get
flutter run -d windows
```

A Windows build requires the supported Visual Studio desktop C++ workload. Check `flutter doctor` for missing components.

Test Windows file selection and Firebase configuration separately. A successful Windows desktop run does not verify Android permissions, camera/gallery behavior, or the Android APK build.

Do not commit local SDK paths, signing passwords, release certificates, Firebase service-account credentials, or private keys.
