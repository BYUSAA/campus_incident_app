# iOS platform notes

The shared Flutter application code includes Firebase and image-picker integrations, but this repository does not currently contain generated iOS Runner/Xcode files.

To add iOS support, use a Mac with Xcode installed and run this command from the project root:

```bash
flutter create --platforms=ios .
```

Register the generated iOS bundle identifier in the Firebase project and run:

```bash
flutterfire configure --platforms=ios
flutter pub get
flutter run
```

The assignment demonstration should use the supported Android target unless iOS is explicitly required. Never commit signing certificates, provisioning profiles, or private keys.
