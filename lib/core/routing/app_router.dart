import 'package:go_router/go_router.dart';

import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/verify_email_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/incidents/screens/create_incident_screen.dart';
import '../../features/incidents/screens/edit_incident_screen.dart';
import '../../features/incidents/screens/incident_details_screen.dart';
import '../../features/incidents/screens/incident_list_screen.dart';
import '../../features/incidents/screens/my_incidents_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/staff/screens/staff_dashboard_screen.dart';
import '../../models/incident.dart';
import '../../shared/layouts/app_scaffold.dart';

class AppRouter {
  AppRouter._();

  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String home = '/home';
  static const String incidents = '/incidents';
  static const String myIncidents = '/my-incidents';
  static const String profile = '/profile';
  static const String createIncident = '/create-incident';
  static const String editIncident = '/edit-incident';
  static const String incidentDetails = '/incident-details';
  static const String staffDashboard = '/staff';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => login,
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: verifyEmail,
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final location = state.matchedLocation;
          final index = location == incidents
              ? 1
              : location == profile
                  ? 3
                  : 0;
          return AppScaffold(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: incidents,
            builder: (context, state) => const IncidentListScreen(),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: myIncidents,
        builder: (context, state) => const MyIncidentsScreen(),
      ),
      GoRoute(
        path: createIncident,
        builder: (context, state) => const CreateIncidentScreen(),
      ),
      GoRoute(
        path: editIncident,
        builder: (context, state) {
          final incident = state.extra;
          if (incident is! Incident) {
            return const _InvalidRouteScreen(
              message: 'The incident to edit was not provided.',
            );
          }
          return EditIncidentScreen(incident: incident);
        },
      ),
      GoRoute(
        path: incidentDetails,
        builder: (context, state) {
          final incident = state.extra;
          if (incident is! Incident) {
            return const _InvalidRouteScreen(
              message: 'The incident details were not provided.',
            );
          }
          return IncidentDetailsScreen(incident: incident);
        },
      ),
      GoRoute(
        path: staffDashboard,
        builder: (context, state) => const StaffDashboardScreen(),
      ),
    ],
  );
}

class _InvalidRouteScreen extends StatelessWidget {
  const _InvalidRouteScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page unavailable')),
      body: Center(child: Text(message)),
    );
  }
}
