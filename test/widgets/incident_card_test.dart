import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/features/incidents/widgets/incident_card.dart';
import 'package:campus_incident_reporter/models/incident.dart';

void main() {
  testWidgets('Incident card shows report title and status', (tester) async {
    final incident = Incident(
      id: 'incident-1',
      title: 'Broken tap',
      description: 'Tap leaking',
      category: 'Water',
      location: 'Library',
      reportedBy: 'student-1',
      status: 'Submitted',
      createdAt: DateTime(2026, 11, 6),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IncidentCard(incident: incident, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Broken tap'), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget);
  });
}
