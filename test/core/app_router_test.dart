import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporter/core/routing/app_router.dart';

void main() {
  group('AppRouter.redirectFor', () {
    String? route({
      required String path,
      bool isInitialized = true,
      bool hasFirebaseUser = true,
      bool emailVerified = true,
      bool hasProfile = true,
      bool isStaff = false,
    }) {
      return AppRouter.redirectFor(
        path: path,
        isInitialized: isInitialized,
        hasFirebaseUser: hasFirebaseUser,
        emailVerified: emailVerified,
        hasProfile: hasProfile,
        isStaff: isStaff,
      );
    }

    test('keeps an unresolved session on the splash screen', () {
      expect(
        route(
          path: AppRouter.home,
          isInitialized: false,
          hasFirebaseUser: false,
          emailVerified: false,
          hasProfile: false,
        ),
        '/splash',
      );
      expect(
        route(
          path: '/splash',
          isInitialized: false,
          hasFirebaseUser: false,
          emailVerified: false,
          hasProfile: false,
        ),
        isNull,
      );
    });

    test('sends signed-out users to login and keeps login/register public', () {
      expect(
        route(
          path: AppRouter.staffDashboard,
          hasFirebaseUser: false,
          emailVerified: false,
          hasProfile: false,
        ),
        AppRouter.login,
      );
      expect(
        route(
          path: AppRouter.login,
          hasFirebaseUser: false,
          emailVerified: false,
          hasProfile: false,
        ),
        isNull,
      );
      expect(
        route(
          path: AppRouter.register,
          hasFirebaseUser: false,
          emailVerified: false,
          hasProfile: false,
        ),
        isNull,
      );
    });

    test('requires email verification before protected pages', () {
      expect(
        route(
          path: AppRouter.home,
          emailVerified: false,
        ),
        AppRouter.verifyEmail,
      );
      expect(
        route(
          path: AppRouter.verifyEmail,
          emailVerified: false,
        ),
        isNull,
      );
    });

    test('routes verified accounts without a profile to recovery', () {
      expect(
        route(
          path: AppRouter.home,
          hasProfile: false,
        ),
        AppRouter.profileRecovery,
      );
      expect(
        route(
          path: AppRouter.profileRecovery,
          hasProfile: false,
        ),
        isNull,
      );
    });

    test('allows students to use student routes and blocks staff routes', () {
      expect(route(path: AppRouter.home), isNull);
      expect(route(path: AppRouter.createIncident), isNull);
      expect(route(path: AppRouter.incidents), isNull);
      expect(route(path: AppRouter.staffDashboard), AppRouter.home);
      expect(route(path: AppRouter.manageIncident), AppRouter.home);
    });

    test('limits staff to the review dashboard and incident management', () {
      expect(
        route(path: AppRouter.staffDashboard, isStaff: true),
        isNull,
      );
      expect(
        route(path: AppRouter.manageIncident, isStaff: true),
        isNull,
      );
      expect(
        route(path: AppRouter.createIncident, isStaff: true),
        AppRouter.staffDashboard,
      );
      expect(
        route(path: AppRouter.profile, isStaff: true),
        AppRouter.staffDashboard,
      );
      expect(
        route(path: AppRouter.myIncidents, isStaff: true),
        AppRouter.staffDashboard,
      );
    });
  });
}
