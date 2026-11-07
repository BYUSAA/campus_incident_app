import 'package:firebase_auth/firebase_auth.dart';

import '../core/utils/validators.dart';
import '../models/app_user.dart';
import '../services/email_verification_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import 'user_repository.dart';

class AuthRepository {
  AuthRepository(this._auth, this._users, this._verification);

  final FirebaseAuthService _auth;
  final UserRepository _users;
  final EmailVerificationService _verification;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final emailError = Validators.validateEmail(normalizedEmail);
    if (emailError != null) throw ArgumentError(emailError);

    final normalizedName = name.trim();
    final nameError = Validators.validateName(normalizedName);
    if (nameError != null) throw ArgumentError(nameError);

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) throw ArgumentError(passwordError);

    final credential = await _auth.register(
      email: normalizedEmail,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw StateError(
        'Firebase did not return the newly created account.',
      );
    }

    try {
      await firebaseUser.updateDisplayName(normalizedName);
      await _users.create(
        AppUser(
          uid: firebaseUser.uid,
          name: normalizedName,
          email: normalizedEmail,
          role: 'student',
        ),
      );
      await _verification.send(firebaseUser);
    } catch (_) {
      // Avoid leaving an Auth account without its required profile.
      try {
        await firebaseUser.delete();
      } catch (_) {
        await _auth.logout();
      }
      rethrow;
    }
  }

  Future<AppUser?> login(String email, String password) async {
    await _auth.login(email, password);
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw StateError(
        'Firebase did not return the signed-in account.',
      );
    }

    await firebaseUser.reload();
    final refreshedUser = _auth.currentUser;
    if (refreshedUser == null || !refreshedUser.emailVerified) {
      await _auth.logout();
      throw StateError(
        'Verify your ALU email address before signing in.',
      );
    }

    final profile = await loadProfile(refreshedUser.uid);
    if (profile == null) {
      await _auth.logout();
      throw StateError(
        'Your account profile is missing. Contact the project administrator.',
      );
    }
    return profile;
  }

  Future<void> resendVerification() => _auth.sendVerificationEmail();

  Future<void> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final emailError = Validators.validateEmail(normalizedEmail);
    if (emailError != null) throw ArgumentError(emailError);
    await _auth.sendPasswordResetEmail(normalizedEmail);
  }

  Future<void> logout() => _auth.logout();
  Future<AppUser?> loadProfile(String uid) => _users.getById(uid);

  Future<bool> refreshVerification() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return false;
    return _verification.refreshAndCheck(firebaseUser);
  }

  factory AuthRepository.createDefault() {
    final firestore = FirestoreService();
    return AuthRepository(
      FirebaseAuthService(),
      UserRepository(firestore),
      EmailVerificationService(),
    );
  }
}