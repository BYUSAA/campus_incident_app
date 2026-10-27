import 'package:cloud_firestore/cloud_firestore.dart';
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore}):_db=firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;
  CollectionReference<Map<String,dynamic>> get users=>_db.collection('users');
  CollectionReference<Map<String,dynamic>> get incidents=>_db.collection('incidents');
  Future<void> saveUser(String uid,Map<String,dynamic> data)=>users.doc(uid).set(data,SetOptions(merge:true));
  Future<Map<String,dynamic>?> getUser(String uid) async {final d=await users.doc(uid).get();return d.data();}
  Future<String> createIncident(Map<String,dynamic> data) async => (await incidents.add(data)).id;
  Stream<QuerySnapshot<Map<String,dynamic>>> watchIncidents()=>incidents.orderBy('createdAt',descending:true).snapshots();
  Stream<QuerySnapshot<Map<String,dynamic>>> watchMyIncidents(String uid)=>incidents.where('reportedBy',isEqualTo:uid).snapshots();
  Future<Map<String,dynamic>?> getIncident(String id) async => (await incidents.doc(id).get()).data();
  Future<void> updateIncident(String id,Map<String,dynamic> data)=>incidents.doc(id).update(data);
  Future<void> deleteIncident(String id)=>incidents.doc(id).delete();
}
