import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/models/incident.dart';

void main() {
  test('incident Firestore payload contains owner, status, and timestamps', () {
    final incident = Incident(
      id: 'incident-10',
      title: 'Damaged door',
      description: 'Door hinge is loose.',
      category: 'Facilities',
      location: 'Block B',
      status: 'Submitted',
      reportedBy: 'student-uid',
      createdAt: DateTime(2026, 11, 6, 9),
    );

    final payload = incident.toMap();

    expect(payload['reportedBy'], 'student-uid');
    expect(payload['status'], 'Submitted');
    expect(payload['createdAt'], isA<Timestamp>());
    expect(payload.containsKey('photoUrls'), isTrue);
  });
}
