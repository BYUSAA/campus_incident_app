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
      final safeExtension = const ['jpg', 'jpeg', 'png', 'webp'].contains(extension)
          ? extension
          : 'jpg';
      final contentType = safeExtension == 'png'
          ? 'image/png'
          : safeExtension == 'webp'
              ? 'image/webp'
              : 'image/jpeg';
      final fileName = '${DateTime.now().microsecondsSinceEpoch}.$safeExtension';
      final reference = _storage.ref().child('incident_photos').child(uid).child(fileName);
      final task = await reference.putFile(
        file,
        SettableMetadata(contentType: contentType),
      );
      return task.ref.getDownloadURL();
    } on StorageException {
      rethrow;
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
