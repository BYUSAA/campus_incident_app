import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/models/incident.dart';

void main() {
  group('Incident model', () {
    test('reads an incident with legacy imageUrl data', () {
      final createdAt = DateTime(2026, 11, 6, 10);
      final incident = Incident.fromMap('report-1', {
        'title': 'Broken water tap',
        'description': 'The tap is leaking.',
        'category': 'Water',
        'location': 'Library',
        'status': 'Submitted',
        'reportedBy': 'student-1',
        'imageUrl': 'https://example.test/photo.jpg',
        'createdAt': Timestamp.fromDate(createdAt),
      });

      expect(incident.id, 'report-1');
      expect(incident.status, 'Submitted');
      expect(incident.imageUrl, 'https://example.test/photo.jpg');
      expect(incident.photoUrls, ['https://example.test/photo.jpg']);
      expect(incident.createdAt, createdAt);
    });

    test('handles missing optional values without throwing', () {
      final incident = Incident.fromMap('report-2', {});

      expect(incident.id, 'report-2');
      expect(incident.status, 'Submitted');
      expect(incident.photoUrls, isEmpty);
      expect(incident.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('ignores malformed optional values instead of crashing', () {
      final incident = Incident.fromMap('report-malformed', {
        'title': 42,
        'description': null,
        'category': false,
        'location': ['not', 'a', 'string'],
        'status': 9,
        'reportedBy': null,
        'imageUrl': 12,
        'photoUrls': ['https://example.test/photo.jpg', 5, null],
        'reporterName': true,
        'assignedTo': {},
        'createdAt': 'not-a-timestamp',
      });

      expect(incident.title, isEmpty);
      expect(incident.category, 'Other');
      expect(incident.status, 'Submitted');
      expect(incident.imageUrl, 'https://example.test/photo.jpg');
      expect(incident.photoUrls, ['https://example.test/photo.jpg']);
      expect(incident.reporterName, isNull);
      expect(incident.assignedTo, isNull);
    });

    test('copyWith can explicitly clear a photo and staff assignment', () {
      final original = Incident(
        id: 'report-4',
        title: 'Broken light',
        description: 'The light does not turn on.',
        category: 'Electricity',
        location: 'Block A',
        status: 'Submitted',
        imageUrl: 'https://example.test/photo.jpg',
        photoUrls: ['https://example.test/photo.jpg'],
        reportedBy: 'student-1',
        reporterName: 'Test Student',
        assignedTo: 'staff-1',
        createdAt: DateTime(2026, 11, 6),
      );

      final updated = original.copyWith(
        imageUrl: null,
        assignedTo: null,
      );

      expect(updated.imageUrl, isNull);
      expect(updated.photoUrls, isEmpty);
      expect(updated.assignedTo, isNull);
      expect(updated.reportedBy, original.reportedBy);
      expect(updated.createdAt, original.createdAt);
    });

    test('serializes the fields used by Firestore rules', () {
      final incident = Incident(
        id: 'report-3',
        title: 'Broken light',
        description: 'The light does not turn on.',
        category: 'Electricity',
        location: 'Block A',
        status: 'Submitted',
        reportedBy: 'student-1',
        reporterName: 'Test Student',
        createdAt: DateTime(2026, 11, 6),
      );

      final data = incident.toMap();
      expect(data['title'], 'Broken light');
      expect(data['reportedBy'], 'student-1');
      expect(data['status'], 'Submitted');
      expect(data['photoUrls'], isEmpty);
      expect(data['createdAt'], isA<Timestamp>());
    });
  });
}
