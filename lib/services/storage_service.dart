import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../core/errors/app_exceptions.dart';

class StorageService {
  StorageService({FirebaseStorage? storage}) : _storage = storage;

  final FirebaseStorage? _storage;

  // Resolve Firebase Storage only when a photo operation is requested.
  // This keeps Authentication and Firestore usable on projects that have not
  // provisioned a Storage bucket (for example, an INZIRA Spark-plan setup).
  FirebaseStorage get _instance => _storage ?? FirebaseStorage.instance;

  Future<String> uploadIncidentPhoto({
    required File file,
    required String uid,
  }) async {
    try {
      final fileSize = await file.length();
      if (fileSize == 0 || fileSize >= 8 * 1024 * 1024) {
        throw StorageException('Choose an image smaller than 8 MB.');
      }

      final extension = file.path.split('.').last.toLowerCase();
      const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      if (!allowedExtensions.contains(extension)) {
        throw StorageException(
          'Use a JPG, PNG, or WEBP image. HEIC and other formats are not supported.',
        );
      }

      final contentType = switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      final fileName = '${DateTime.now().microsecondsSinceEpoch}.$extension';
      final reference = _instance
          .ref()
          .child('incident_photos')
          .child(uid)
          .child(fileName);
      final task = await reference.putFile(
        file,
        SettableMetadata(contentType: contentType),
      );
      return await task.ref.getDownloadURL();
    } on StorageException {
      rethrow;
    } on FirebaseException catch (error) {
      if (_isStorageUnavailable(error.code)) {
        throw StorageException(
          'Photo uploads are not available for this Firebase project yet. '
          'Cloud Storage requires a provisioned bucket and the Blaze '
          'pay-as-you-go plan. You can still submit your report without a photo.',
          error.code,
        );
      }
      throw StorageException(
        'Firebase Storage could not upload this photo: '
        '${error.message ?? error.code}',
        error.code,
      );
    } catch (error) {
      throw StorageException('Could not upload the incident photo: $error');
    }
  }

  Future<void> deletePhotoByUrl(String url) async {
    try {
      await _instance.refFromURL(url).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
  }

  bool _isStorageUnavailable(String code) {
    return const {
      'no-default-bucket',
      'bucket-not-found',
      'quota-exceeded',
      'storage/no-default-bucket',
      'storage/bucket-not-found',
      'storage/quota-exceeded',
    }.contains(code);
  }
}
