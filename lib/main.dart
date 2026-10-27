import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/incident_repository.dart';
import 'repositories/user_repository.dart';
import 'services/email_verification_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final authService = FirebaseAuthService();
  final firestore = FirestoreService();
  final users = UserRepository(firestore);
  final authRepository = AuthRepository(authService, users, EmailVerificationService());
  final incidents = IncidentRepository(firestore, StorageService());
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)..listenToAuthChanges()),
    ChangeNotifierProvider(create: (_) => IncidentProvider(incidents)),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ], child: const CampusIncidentApp()));
}
