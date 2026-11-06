import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class IncidentRepository {
  IncidentRepository(this._firestore, this._storage);

  final FirestoreService _firestore;
  final StorageService _storage;

  Stream<List<Incident>> watchAll() {
    return _firestore.watchIncidents().map(
          (snapshot) => snapshot.docs
              .map((document) => Incident.fromMap(document.id, document.data()))
              .toList(growable: false),
        );
  }

  Stream<List<Incident>> watchMine(String uid) {
    return _firestore.watchMyIncidents(uid).map(
          (snapshot) => snapshot.docs
              .map((document) => Incident.fromMap(document.id, document.data()))
              .toList(growable: false),
        );
  }

  Future<String> create({
    required String title,
    required String description,
    required String category,
    required String location,
    required String uid,
    required String reporterName,
    File? photo,
  }) async {
    String? imageUrl;
    if (photo != null) {
      imageUrl = await _storage.uploadIncidentPhoto(file: photo, uid: uid);
    }

    try {
      return await _firestore.createIncident({
        'title': title.trim(),
        'description': description.trim(),
        'category': category,
        'location': location.trim(),
        'reportedBy': uid,
        'reporterName': reporterName,
        'status': 'Submitted',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
        'photoUrls': imageUrl == null ? <String>[] : <String>[imageUrl],
        'assignedTo': null,
      });
    } catch (_) {
      if (imageUrl != null) await _storage.deletePhotoByUrl(imageUrl);
      rethrow;
    }
  }

  Future<Incident?> getById(String id) async {
    final data = await _firestore.getIncident(id);
    return data == null ? null : Incident.fromMap(id, data);
  }

  Future<void> update(Incident incident, {File? photo}) async {
    final oldImageUrl = incident.imageUrl;
    final newImageUrl = photo == null
        ? oldImageUrl
        : await _storage.uploadIncidentPhoto(file: photo, uid: incident.reportedBy);
    final photos = newImageUrl == null ? <String>[] : <String>[newImageUrl];

    try {
      await _firestore.updateIncident(incident.id, {
        'title': incident.title.trim(),
        'description': incident.description.trim(),
        'category': incident.category,
        'location': incident.location.trim(),
        'imageUrl': newImageUrl,
        'photoUrls': photos,
        'reporterName': incident.reporterName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      if (photo != null && newImageUrl != null) {
        await _storage.deletePhotoByUrl(newImageUrl);
      }
      rethrow;
    }

    if (photo != null && oldImageUrl != null && oldImageUrl != newImageUrl) {
      await _storage.deletePhotoByUrl(oldImageUrl);
    }
  }

  Future<void> updateStatus(String id, String status) {
    const allowed = ['Submitted', 'In Progress', 'Resolved'];
    if (!allowed.contains(status)) {
      throw ArgumentError.value(status, 'status', 'Unsupported incident status.');
    }
    return _firestore.updateIncident(id, {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String id) async {
    final incident = await getById(id);
    await _firestore.deleteIncident(id);
    if (incident == null) return;

    final photos = incident.photoUrls.isNotEmpty
        ? incident.photoUrls
        : (incident.imageUrl == null ? <String>[] : <String>[incident.imageUrl!]);
    for (final url in photos) {
      await _storage.deletePhotoByUrl(url);
    }
  }
}
