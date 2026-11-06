import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _incidents => _db.collection('incidents');

  Future<void> saveUser(String uid, Map<String, dynamic> data) {
    return _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    return snapshot.data();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchIncidents() {
    return _incidents.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyIncidents(String uid) {
    return _incidents
        .where('reportedBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String> createIncident(Map<String, dynamic> data) async {
    final reference = _incidents.doc();
    await reference.set(data);
    return reference.id;
  }

  Future<Map<String, dynamic>?> getIncident(String id) async {
    final snapshot = await _incidents.doc(id).get();
    return snapshot.data();
  }

  Future<void> updateIncident(String id, Map<String, dynamic> data) {
    return _incidents.doc(id).update(data);
  }

  Future<void> deleteIncident(String id) {
    return _incidents.doc(id).delete();
  }
}
