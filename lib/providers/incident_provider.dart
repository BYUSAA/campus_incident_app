import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/firestore_service.dart';

class IncidentProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Incident> _incidents = [];
  bool _isLoading = false;

  List<Incident> get incidents => _incidents;
  bool get isLoading => _isLoading;

  void fetchUserIncidents(String uid) {
    _isLoading = true;
    notifyListeners();
    
    _firestoreService.getUserIncidents(uid).listen((data) {
      _incidents = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> submitIncident(Incident incident) async {
    await _firestoreService.createIncident(incident);
  }

  Future<void> updateStatus(String id, String status) async {
    await _firestoreService.updateIncidentStatus(id, status);
  }
}