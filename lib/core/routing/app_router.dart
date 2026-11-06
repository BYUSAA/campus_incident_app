// Add these imports:
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/verify_email_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/layouts/app_scaffold.dart';

// Replace your 'routes' list with this:
routes: [
  GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
  GoRoute(path: '/verify-email', builder: (context, state) => const VerifyEmailScreen()),
  
  // ShellRoute wraps screens with the Bottom Navigation Bar
  ShellRoute(
    builder: (context, state, child) {
      int index = 0;
      if (state.matchedLocation == '/incidents') index = 1;
      if (state.matchedLocation == '/profile') index = 3;
      // Note: '/create-incident' is usually a full screen modal, not in the nav bar, but we map it here just in case.
      return AppScaffold(currentIndex: index, child: child);
    },
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/incidents', builder: (context, state) => const IncidentListScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    ],
  ),
  
  // Full screen routes (no bottom nav)
  GoRoute(path: '/create-incident', builder: (context, state) => const CreateIncidentScreen()),
  GoRoute(
    path: '/edit-incident',
    builder: (context, state) => EditIncidentScreen(incident: state.extra as Incident),
  ),
  GoRoute(
    path: '/incident-details',
    builder: (context, state) => IncidentDetailsScreen(incident: state.extra as Incident),
  ),
],