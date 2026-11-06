import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/errors/app_exceptions.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadIncidentImage(File file, String incidentId) async {
    try {
      final ref = _storage.ref().child('incidents').child(incidentId).child('image.jpg');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw StorageException('Failed to upload image: $e');
    }
  }
}