import 'package:flutter/material.dart';
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
import '../../features/splash/screens/splash_screen.dart';
import '../../features/staff/screens/manage_incident_screen.dart';
import '../../features/staff/screens/staff_dashboard_screen.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../shared/layouts/app_scaffold.dart';

class AppRouter {
  AppRouter._();

  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const home = '/home';
  static const incidents = '/incidents';
  static const myIncidents = '/my-incidents';
  static const profile = '/profile';
  static const createIncident = '/create-incident';
  static const editIncident = '/edit-incident';
  static const incidentDetails = '/incident-details';
  static const staffDashboard = '/staff';
  static const manageIncident = '/staff/manage';

  static GoRouter create(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final path = state.matchedLocation;
        if (!auth.isInitialized) {
          return path == '/splash' ? null : '/splash';
        }

        final firebaseUser = auth.firebaseUser;
        if (firebaseUser == null) {
          return path == login || path == register ? null : login;
        }

        if (!auth.isEmailVerified) {
          return path == verifyEmail ? null : verifyEmail;
        }

        if (path == '/splash' || path == login || path == register || path == verifyEmail) {
          return auth.user?.role == 'staff' ? staffDashboard : home;
        }

        if ((path == staffDashboard || path == manageIncident) &&
            auth.user?.role != 'staff') {
          return home;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => '/splash',
        ),
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
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
            final path = state.matchedLocation;
            final index = path == incidents
                ? 1
                : path == profile
                    ? 3
                    : 0;
            return AppScaffold(currentIndex: index, child: child);
          },
          routes: [
            GoRoute(path: home, builder: (context, state) => const HomeScreen()),
            GoRoute(path: incidents, builder: (context, state) => const IncidentListScreen()),
            GoRoute(path: profile, builder: (context, state) => const ProfileScreen()),
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
            return incident is Incident
                ? EditIncidentScreen(incident: incident)
                : const _InvalidRouteScreen(message: 'The incident to edit was not provided.');
          },
        ),
        GoRoute(
          path: incidentDetails,
          builder: (context, state) {
            final incident = state.extra;
            return incident is Incident
                ? IncidentDetailsScreen(incident: incident)
                : const _InvalidRouteScreen(message: 'The incident details were not provided.');
          },
        ),
        GoRoute(
          path: staffDashboard,
          builder: (context, state) => const StaffDashboardScreen(),
        ),
        GoRoute(
          path: manageIncident,
          builder: (context, state) {
            final incident = state.extra;
            return incident is Incident
                ? ManageIncidentScreen(incident: incident)
                : const _InvalidRouteScreen(message: 'The incident to manage was not provided.');
          },
        ),
      ],
    );
  }
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
