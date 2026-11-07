import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationService {
  Future<void> send(User user) async {
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> refreshAndCheck(User user) async {
    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;
    if (refreshedUser == null) return false;

    // Firestore/Storage rules authorize incident actions with the
    // email_verified claim from the Firebase ID token. Force a new token
    // after email verification so the rule engine sees the updated claim.
    await refreshedUser.getIdToken(true);
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }
}