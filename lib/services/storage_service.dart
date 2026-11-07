import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../core/errors/app_exceptions.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

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
      final reference = _storage
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
      throw StorageException(
        'Firebase Storage could not upload this photo: ${error.message ?? error.code}',
      );
    } catch (error) {
      throw StorageException('Could not upload the incident photo: $error');
    }
  }

  Future<void> deletePhotoByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
  }
}