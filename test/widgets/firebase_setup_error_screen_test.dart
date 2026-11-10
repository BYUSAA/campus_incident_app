import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/features/splash/screens/firebase_setup_error_screen.dart';

void main() {
  testWidgets('Firebase setup screen points to the INZIRA project', (tester) async {
    await tester.pumpWidget(
      const FirebaseSetupErrorApp(
        error: UnsupportedError('Firebase options have not been generated.'),
      ),
    );

    expect(find.textContaining('INZIRA'), findsWidgets);
    expect(find.textContaining('inzira-498621'), findsWidgets);
    expect(
      find.text(r'.\\tooling\\bootstrap-firebase.ps1'),
      findsOneWidget,
    );
    expect(find.textContaining('YOUR_FIREBASE_PROJECT_ID'), findsNothing);
    expect(find.textContaining('Blaze pay-as-you-go plan'), findsOneWidget);
  });
}
