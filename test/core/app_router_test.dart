import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/core/routing/app_router.dart';

void main() {
  group('AppRouter.redirectFor', () {
    const signedOut = {
      'isInitialized': true,
      'hasFirebaseUser': false,
      'emailVerified': false,
      'hasProfile': false,
      'isStaff': false,
    };

    const verifiedStudent = {
      'isInitialized': true,
      'hasFirebaseUser': true,
      'emailVerified': true,
      'hasProfile': true,
      'isStaff': false,
    };

    const verifiedStaff = {
      'isInitialized': true,
      'hasFirebaseUser': true,
      'emailVerified': true,
      'hasProfile': true,
      'isStaff': true,
    };

    test('keeps an unresolved session on the splash screen', () {
      expect(
        AppRouter.redirectFor(
          path: AppRouter.home,
          isInitialized: false,
          hasFirebaseUser: false,
          emailVerified: false,
          hasProfile: false,
          isStaff: false,
        ),
        '/splash',
      );
    });

    test('sends signed-out users to login and keeps login/register public', () {
      expect(
        AppRouter.redirectFor(path: AppRouter.staffDashboard, ...signedOut),
        AppRouter.login,
      );
      expect(
        AppRouter.redirectFor(path: AppRouter.login, ...signedOut),
        isNull,
      );
      expect(
        AppRouter.redirectFor(path: AppRouter.register, ...signedOut),
        isNull,
      );
    });

    test('requires email verification before protected pages', () {
      expect(
        AppRouter.redirectFor(
          path: AppRouter.home,
          isInitialized: true,
          hasFirebaseUser: true,
          emailVerified: false,
          hasProfile: true,
          isStaff: false,
        ),
        AppRouter.verifyEmail,
      );
      expect(
        AppRouter.redirectFor(
          path: AppRouter.verifyEmail,
          isInitialized: true,
          hasFirebaseUser: true,
          emailVerified: false,
          hasProfile: true,
          isStaff: false,
        ),
        isNull,
      );
    });

    test('routes verified accounts without a profile to recovery', () {
      expect(
        AppRouter.redirectFor(
          path: AppRouter.home,
          isInitialized: true,
          hasFirebaseUser: true,
          emailVerified: true,
          hasProfile: false,
          isStaff: false,
        ),
        AppRouter.profileRecovery,
      );
    });

    test('allows students to use student routes and blocks staff routes', () {
      expect(
        AppRouter.redirectFor(path: AppRouter.home, ...verifiedStudent),
        isNull,
      );
      expect(
        AppRouter.redirectFor(path: AppRouter.createIncident, ...verifiedStudent),
        isNull,
      );
      expect(
        AppRouter.redirectFor(path: AppRouter.staffDashboard, ...verifiedStudent),
        AppRouter.home,
      );
      expect(
        AppRouter.redirectFor(path: AppRouter.manageIncident, ...verifiedStudent),
        AppRouter.home,
      );
    });

    test('limits staff to the review dashboard and incident management', () {
      expect(
        AppRouter.redirectFor(path: AppRouter.staffDashboard, ...verifiedStaff),
        isNull,
      );
      expect(
        AppRouter.redirectFor(path: AppRouter.manageIncident, ...verifiedStaff),
        isNull,
      );
      expect(
        AppRouter.redirectFor(path: AppRouter.createIncident, ...verifiedStaff),
        AppRouter.staffDashboard,
      );
      expect(
        AppRouter.redirectFor(path: AppRouter.profile, ...verifiedStaff),
        AppRouter.staffDashboard,
      );
    });
  });
}
