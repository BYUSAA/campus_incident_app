import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
class StorageService {
  StorageService({FirebaseStorage? storage}):_storage=storage ?? FirebaseStorage.instance;
  final FirebaseStorage _storage;
  Future<String> uploadIncidentPhoto({required File file,required String uid}) async {
    final ref=_storage.ref('incident_photos/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final snap=await ref.putFile(file,SettableMetadata(contentType:'image/jpeg'));
    return snap.ref.getDownloadURL();
  }
}
