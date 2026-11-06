import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create Incident
  Future<void> createIncident(Incident incident) async {
    await _db.collection('incidents').add(incident.toMap());
  }

  // Stream of user's incidents
  Stream<List<Incident>> getUserIncidents(String uid) {
    return _db.collection('incidents')
        .where('reportedBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Incident.fromMap(doc.id, doc.data())).toList());
  }

  // Update Status (Staff)
  Future<void> updateIncidentStatus(String incidentId, String newStatus) async {
    await _db.collection('incidents').doc(incidentId).update({'status': newStatus});
  }
}