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

    // The Auth account and its Firestore profile form the durable identity.
    // Roll back Auth only if the profile itself cannot be created; a temporary
    // verification-email outage must not leave an orphaned profile document.
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
    } catch (_) {
      try {
        await firebaseUser.delete();
      } catch (_) {
        await _auth.logout();
      }
      rethrow;
    }

    try {
      await _verification.send(firebaseUser);
    } catch (error) {
      throw StateError(
        'Your account was created, but the verification email could not be sent. '
        'Use Resend verification email on the next screen. $error',
      );
    }
  }

  Future<AppUser?> login(String email, String password) async {
    final emailError = Validators.validateEmail(email);
    if (emailError != null) throw ArgumentError(emailError);

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

  Future<AppUser?> updateProfileName(String uid, String name) async {
    final error = Validators.validateName(name);
    if (error != null) throw ArgumentError(error);
    await _users.updateName(uid, name);
    return loadProfile(uid);
  }

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