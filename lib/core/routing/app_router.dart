import 'package:flutter/material.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/verify_email_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/incidents/screens/incident_list_screen.dart';
import '../../features/incidents/screens/create_incident_screen.dart';
import '../../features/incidents/screens/incident_details_screen.dart';
import '../../features/incidents/screens/my_incidents_screen.dart';
import '../../features/staff/screens/staff_dashboard_screen.dart';
import '../../features/staff/screens/manage_incident_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
class AppRouter {
  AppRouter._();
  static const splash='/', login='/login', register='/register', verifyEmail='/verify-email', home='/home', incidents='/incidents', createIncident='/incidents/create', incidentDetails='/incidents/details', myIncidents='/incidents/mine', staff='/staff', manageStaff='/staff/manage', profile='/profile', settings='/settings';
  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    late final Widget page;
    switch (s.name) {
      case splash: page=const SplashScreen(); break;
      case login: page=const LoginScreen(); break;
      case register: page=const RegisterScreen(); break;
      case verifyEmail: page=const VerifyEmailScreen(); break;
      case home: page=const HomeScreen(); break;
      case incidents: page=const IncidentListScreen(); break;
      case createIncident: page=const CreateIncidentScreen(); break;
      case incidentDetails: page=IncidentDetailsScreen(incidentId: s.arguments as String); break;
      case myIncidents: page=const MyIncidentsScreen(); break;
      case staff: page=const StaffDashboardScreen(); break;
      case profile: page=const ProfileScreen(); break;
      case AppRouter.settings: page=const SettingsScreen(); break;
      case manageStaff: page=ManageIncidentScreen(incidentId: s.arguments as String); break;
      default: page=const LoginScreen();
    }
    return MaterialPageRoute<void>(builder: (_) => page, settings: s);
  }
}
