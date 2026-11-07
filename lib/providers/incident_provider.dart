import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../repositories/incident_repository.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class IncidentProvider extends ChangeNotifier {
  IncidentProvider({IncidentRepository? repository})
      : _repository = repository ??
            IncidentRepository(FirestoreService(), StorageService());

  final IncidentRepository _repository;
  StreamSubscription<List<Incident>>? _subscription;

  List<Incident> _incidents = const [];
  bool _isLoading = false;
  String? _errorMessage;
  int _streamVersion = 0;

  List<Incident> get incidents => List.unmodifiable(_incidents);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void watchForUser(AppUser user) {
    if (user.role == 'staff') {
      fetchAllIncidents();
    } else {
      fetchUserIncidents(user.uid);
    }
  }

  void fetchUserIncidents(String uid) {
    _subscribe(_repository.watchMine(uid));
  }

  void fetchAllIncidents() {
    _subscribe(_repository.watchAll());
  }

  void _subscribe(Stream<List<Incident>> stream) {
    final version = ++_streamVersion;
    _subscription?.cancel();
    _incidents = const [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = stream.listen(
      (items) {
        if (version != _streamVersion) return;
        _incidents = items;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        if (version != _streamVersion) return;
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> submitIncident(Incident incident, {File? photo}) async {
    await _repository.create(
      title: incident.title,
      description: incident.description,
      category: incident.category,
      location: incident.location,
      uid: incident.reportedBy,
      reporterName: incident.reporterName ?? '',
      photo: photo,
    );
  }

  Future<void> updateIncident(
    Incident incident, {
    File? photo,
    bool removePhoto = false,
  }) {
    return _repository.update(
      incident,
      photo: photo,
      removePhoto: removePhoto,
    );
  }

  Future<void> deleteIncident(String id) => _repository.delete(id);

  Future<void> updateStatus(String id, String status) {
    return _repository.updateStatus(id, status);
  }

  @override
  void dispose() {
    ++_streamVersion;
    _subscription?.cancel();
    super.dispose();
  }
}
