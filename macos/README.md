# macOS desktop platform notes

macOS desktop support is optional. This repository does not currently include generated macOS Runner/Xcode files.

On a Mac with Xcode installed, run from the project root:

```bash
flutter create --platforms=macos .
flutter run -d macos
```

Configure Firebase for macOS separately if this platform is needed. Keep signing identities, certificates, and provisioning files out of Git.
