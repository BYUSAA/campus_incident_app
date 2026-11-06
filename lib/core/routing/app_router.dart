import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/incidents/screens/create_incident_screen.dart';
import '../../features/incidents/screens/incident_details_screen.dart';
import '../../features/incidents/screens/my_incidents_screen.dart';
import '../../models/incident.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.user != null;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/create-incident', builder: (context, state) => const CreateIncidentScreen()),
      GoRoute(path: '/my-incidents', builder: (context, state) => const MyIncidentsScreen()),
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