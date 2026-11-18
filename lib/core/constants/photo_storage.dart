/// Evidence photos are stored in Cloudflare R2 behind the Worker in
/// `cloudflare/photo-worker.js`. The Worker verifies the caller's Firebase ID
/// token, so this URL is not a secret.
///
/// Override at build time with:
/// `flutter run --dart-define=PHOTO_API_URL=https://<worker>.workers.dev`
class PhotoStorage {
  PhotoStorage._();

  static const String apiBaseUrl = String.fromEnvironment(
    'PHOTO_API_URL',
    defaultValue: 'https://incident-photos-api.m-byusa.workers.dev',
  );

  static const int maxBytes = 8 * 1024 * 1024;

  /// Whether [url] points at the photo Worker (and so needs a sign-in token).
  static bool isWorkerUrl(String url) => url.startsWith('$apiBaseUrl/photos/');
}
