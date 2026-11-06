import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/incident.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/incidents/screens/create_incident_screen.dart';
import '../../features/incidents/screens/edit_incident_screen.dart';
import '../../features/incidents/screens/incident_details_screen.dart';
import '../../features/incidents/screens/incident_list_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.user != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // Add RegisterRoute here if needed
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/incidents', builder: (context, state) => const IncidentListScreen()),
      GoRoute(path: '/create-incident', builder: (context, state) => const CreateIncidentScreen()),
      GoRoute(
        path: '/edit-incident',
        builder: (context, state) {
          final incident = state.extra as Incident;
          return EditIncidentScreen(incident: incident);
        },
      ),
      GoRoute(
        path: '/incident-details',
        builder: (context, state) {
          final incident = state.extra as Incident;
          return IncidentDetailsScreen(incident: incident);
        },
      ),
    ],
  );
}