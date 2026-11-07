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
  String? _activeScope;
  int _streamVersion = 0;

  List<Incident> get incidents => List.unmodifiable(_incidents);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get activeScope => _activeScope;

  Incident? findById(String id) {
    for (final incident in _incidents) {
      if (incident.id == id) return incident;
    }
    return null;
  }

  /// Selects one live feed for the current authenticated profile.
  ///
  /// Repeated calls for the same profile do not create duplicate listeners.
  /// Set [notify] to false when this is called by a Provider proxy update
  /// during a widget build; the related AuthProvider update already rebuilds
  /// dependent widgets.
  void watchForUser(AppUser? user, {bool notify = true}) {
    if (user == null) {
      clear(notify: notify);
      return;
    }

    final scope = user.isStaff ? 'staff:all' : 'student:${user.uid}';
    if (_activeScope == scope && _subscription != null) return;

    if (user.isStaff) {
      _subscribe(_repository.watchAll(), scope: scope, notify: notify);
    } else {
      _subscribe(
        _repository.watchMine(user.uid),
        scope: scope,
        notify: notify,
      );
    }
  }

  void fetchUserIncidents(String uid) {
    final scope = 'student:$uid';
    if (_activeScope == scope && _subscription != null) return;
    _subscribe(_repository.watchMine(uid), scope: scope);
  }

  void fetchAllIncidents() {
    const scope = 'staff:all';
    if (_activeScope == scope && _subscription != null) return;
    _subscribe(_repository.watchAll(), scope: scope);
  }

  Future<void> refresh() async {
    final scope = _activeScope;
    if (scope == null) return;

    final firstSnapshot = Completer<void>();
    void completeRefresh() {
      if (!firstSnapshot.isCompleted) firstSnapshot.complete();
    }

    if (scope == 'staff:all') {
      _subscribe(
        _repository.watchAll(),
        scope: scope,
        force: true,
        onFirstSnapshot: completeRefresh,
      );
    } else if (scope.startsWith('student:')) {
      final uid = scope.substring('student:'.length);
      _subscribe(
        _repository.watchMine(uid),
        scope: scope,
        force: true,
        onFirstSnapshot: completeRefresh,
      );
    } else {
      return;
    }

    await firstSnapshot.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {},
    );
  }

  void clear({bool notify = true}) {
    if (_activeScope == null &&
        _subscription == null &&
        _incidents.isEmpty &&
        !_isLoading &&
        _errorMessage == null) {
      return;
    }

    ++_streamVersion;
    final previous = _subscription;
    _subscription = null;
    _activeScope = null;
    _incidents = const [];
    _isLoading = false;
    _errorMessage = null;
    if (previous != null) unawaited(previous.cancel());
    if (notify) notifyListeners();
  }

  void _subscribe(
    Stream<List<Incident>> stream, {
    required String scope,
    bool force = false,
    bool notify = true,
    VoidCallback? onFirstSnapshot,
  }) {
    if (!force && _activeScope == scope && _subscription != null) return;

    final version = ++_streamVersion;
    final previous = _subscription;
    _subscription = null;
    _activeScope = scope;
    _incidents = const [];
    _isLoading = true;
    _errorMessage = null;
    if (previous != null) unawaited(previous.cancel());
    if (notify) notifyListeners();

    var didReceiveFirstEvent = false;
    void finishFirstEvent() {
      if (didReceiveFirstEvent) return;
      didReceiveFirstEvent = true;
      onFirstSnapshot?.call();
    }

    _subscription = stream.listen(
      (items) {
        if (version != _streamVersion) return;
        finishFirstEvent();
        _incidents = items;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        if (version != _streamVersion) return;
        finishFirstEvent();
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
    _subscription = null;
    _activeScope = null;
    super.dispose();
  }
}
