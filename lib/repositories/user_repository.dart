import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../services/firestore_service.dart';

class UserRepository {
  UserRepository(this._firestore);

  final FirestoreService _firestore;

  Future<void> create(AppUser user) {
    return _firestore.saveUser(user.uid, {
      ...user.toMap(),
      'emailVerified': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateName(String uid, String name) {\n    return _firestore.saveUser(uid, {\n      'name': name.trim(),\n      'updatedAt': FieldValue.serverTimestamp(),\n    });\n  }\n\n  Future<AppUser?> getById(String uid) async {
    final data = await _firestore.getUser(uid);
    return data == null ? null : AppUser.fromMap(data);
  }
}