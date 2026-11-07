import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/models/app_user.dart';
import 'package:campus_incident_reporter/models/incident.dart';
import 'package:campus_incident_reporter/providers/incident_provider.dart';
import 'package:campus_incident_reporter/repositories/incident_repository.dart';

class FakeIncidentRepository implements IncidentRepository {
  final sample = Incident(
    id: 'incident-1',
    title: 'Leaking tap',
    description: 'Water is leaking.',
    category: 'Water',
    location: 'Library',
    status: 'Submitted',
    reportedBy: 'student-1',
    createdAt: DateTime(2026, 11, 6),
  );

  String? lastWatchedUid;
  String? lastCreatedBy;
  String? lastCreatedTitle;
  String? lastUpdatedStatus;
  String? lastDeletedId;
  int watchAllCalls = 0;

  @override
  Stream<List<Incident>> watchAll() {
    watchAllCalls++;
    return Stream.value([sample]);
  }

  @override
  Stream<List<Incident>> watchMine(String uid) {
    lastWatchedUid = uid;
    return Stream.value(
      uid == 'student-1' ? [sample] : <Incident>[],
    );
  }

  @override
  Future<String> create({
    required String title,
    required String description,
    required String category,
    required String location,
    required String uid,
    required String reporterName,
    File? photo,
  }) async {
    lastCreatedBy = uid;
    lastCreatedTitle = title;
    return 'created-incident';
  }

  @override
  Future<Incident?> getById(String id) async =>
      id == sample.id ? sample : null;

  @override
  Future<void> update(Incident incident, {File? photo}) async {}

  @override
  Future<void> updateStatus(String id, String status) async {
    lastUpdatedStatus = status;
  }

  @override
  Future<void> delete(String id) async {
    lastDeletedId = id;
  }
}

void main() {
  group('IncidentProvider', () {
    test('loads reports for the selected student', () async {
      final repository = FakeIncidentRepository();
      final provider = IncidentProvider(repository: repository);

      provider.fetchUserIncidents('student-1');
      await Future<void>.delayed(Duration.zero);

      expect(repository.lastWatchedUid, 'student-1');
      expect(provider.incidents, hasLength(1));
      expect(provider.incidents.single.title, 'Leaking tap');
      expect(provider.isLoading, isFalse);
      provider.dispose();
    });

    test('clears previously loaded reports when the user changes', () async {
      final provider = IncidentProvider(
        repository: FakeIncidentRepository(),
      );

      provider.fetchUserIncidents('student-1');
      await Future<void>.delayed(Duration.zero);
      expect(provider.incidents, hasLength(1));

      provider.fetchUserIncidents('student-2');
      await Future<void>.delayed(Duration.zero);

      expect(provider.incidents, isEmpty);
      provider.dispose();
    });

    test('uses the all-incidents stream for an authorized staff user', () async {
      final repository = FakeIncidentRepository();
      final provider = IncidentProvider(repository: repository);
      const staff = AppUser(
        uid: 'staff-1',
        name: 'Staff Member',
        email: 'staff-1@alustudent.com',
        role: 'staff',
      );

      provider.watchForUser(staff);
      await Future<void>.delayed(Duration.zero);

      expect(repository.watchAllCalls, 1);
      expect(provider.incidents, hasLength(1));
      provider.dispose();
    });

    test('submits the incident with its owner and report details', () async {
      final repository = FakeIncidentRepository();
      final provider = IncidentProvider(repository: repository);

      await provider.submitIncident(repository.sample);

      expect(repository.lastCreatedBy, 'student-1');
      expect(repository.lastCreatedTitle, 'Leaking tap');
      provider.dispose();
    });

    test('forwards status updates and report deletion', () async {
      final repository = FakeIncidentRepository();
      final provider = IncidentProvider(repository: repository);

      await provider.updateStatus('incident-1', 'In Progress');
      await provider.deleteIncident('incident-1');

      expect(repository.lastUpdatedStatus, 'In Progress');
      expect(repository.lastDeletedId, 'incident-1');
      provider.dispose();
    });
  });
}
