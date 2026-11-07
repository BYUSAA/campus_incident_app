import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/splash/screens/firebase_setup_error_screen.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    runApp(FirebaseSetupErrorApp(error: error));
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, IncidentProvider>(
          create: (_) => IncidentProvider(),
          update: (_, auth, incidents) {
            final provider = incidents ?? IncidentProvider();
            if (auth.isInitialized && auth.isAuthenticated) {
              provider.watchForUser(auth.user);
            } else {
              provider.clear();
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
      ],
      child: const MyApp(),
    ),
  );
}
