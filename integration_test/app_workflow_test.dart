import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:campus_incident_reporter/app.dart';
import 'package:campus_incident_reporter/firebase_options.dart';
import 'package:campus_incident_reporter/providers/auth_provider.dart';
import 'package:campus_incident_reporter/providers/incident_provider.dart';
import 'package:campus_incident_reporter/providers/theme_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('a signed-out user is directed to the login screen', (tester) async {
    await FirebaseAuth.instance.signOut();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => IncidentProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
