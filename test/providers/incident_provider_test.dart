import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/models/incident.dart';
import 'package:campus_incident_reporter/repositories/incident_repository.dart';
import 'package:campus_incident_reporter/providers/incident_provider.dart';

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

  String? lastCreatedBy;
  String? lastUpdatedStatus;

  @override
  Stream<List<Incident>> watchAll() => Stream.value([sample]);

  @override
  Stream<List<Incident>> watchMine(String uid) =>
      Stream.value(uid == 'student-1' ? [sample] : <Incident>[]);

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
    return 'created-incident';
  }

  @override
  Future<Incident?> getById(String id) async => id == sample.id ? sample : null;

  @override
  Future<void> update(Incident incident, {File? photo}) async {}

  @override
  Future<void> updateStatus(String id, String status) async {
    lastUpdatedStatus = status;
  }

  @override
  Future<void> delete(String id) async {}
}

void main() {
  group('IncidentProvider', () {
    test('loads reports for the selected student', () async {
      final provider = IncidentProvider(repository: FakeIncidentRepository());

      provider.fetchUserIncidents('student-1');
      await Future<void>.delayed(Duration.zero);

      expect(provider.incidents, hasLength(1));
      expect(provider.incidents.single.title, 'Leaking tap');
      expect(provider.isLoading, isFalse);
      provider.dispose();
    });

    test('uses the all-incidents stream for staff', () async {
      final provider = IncidentProvider(repository: FakeIncidentRepository());

      provider.fetchAllIncidents();
      await Future<void>.delayed(Duration.zero);

      expect(provider.incidents, hasLength(1));
      provider.dispose();
    });
  });
}
