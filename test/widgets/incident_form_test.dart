import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/features/incidents/widgets/incident_form.dart';

void main() {
  testWidgets('incident form validates required fields before submission', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: IncidentForm(onSuccess: _noop),
          ),
        ),
      ),
    );

    // The submit button sits below the photo picker, outside the default
    // 800x600 test viewport; scroll it into view before tapping.
    await tester.ensureVisible(find.text('Submit Report'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle();

    expect(find.text('Title is required'), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
    expect(find.text('Location is required'), findsOneWidget);
  });
}

void _noop() {}
