# Windows desktop platform notes

Windows desktop support is optional and is not the assignment's mobile demonstration target. Generated Windows runner files are not included yet.

On Windows with the Flutter desktop toolchain installed, run from the repository root:

```bash
flutter create --platforms=windows .
flutter run -d windows
```

The primary workflow should still be tested on an Android emulator or physical Android phone. Firebase configuration must be generated for each platform that is actually used.
