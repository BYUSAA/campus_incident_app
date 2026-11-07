import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_constants.dart';
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
    if (!normalizedEmail.endsWith(AppConstants.aluStudentDomain)) {
      throw ArgumentError('Please register with your @alustudent.com email address.');
    }
    final normalizedName = name.trim();
    if (normalizedName.isEmpty || normalizedName.length > 80) {
      throw ArgumentError('Your name must be between 1 and 80 characters.');
    }
    if (normalizedEmail.length > 254 ||
        !RegExp(r'^[^\\s@]+@[^\\s@]+\\.[^\\s@]+

    final credential = await _auth.register(
      email: normalizedEmail,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw StateError('Firebase did not return the newly created account.');
    }

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
  }

  Future<AppUser?> login(String email, String password) async {
    await _auth.login(email, password);
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw StateError('Firebase did not return the signed-in account.');
    }

    await firebaseUser.reload();
    final refreshedUser = _auth.currentUser;
    if (refreshedUser == null || !refreshedUser.emailVerified) {
      await _auth.logout();
      throw StateError('Verify your ALU email address before signing in.');
    }

    final profile = await loadProfile(refreshedUser.uid);
    if (profile == null) {
      throw StateError('Your account profile is missing. Contact the project administrator.');
    }
    return profile;
  }

  Future<void> resendVerification() => _auth.sendVerificationEmail();

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
).hasMatch(normalizedEmail)) {
      throw ArgumentError('Enter a valid ALU student email address.');
    }
    if (password.length < 6) {
      throw ArgumentError('Your password must be at least 6 characters.');
    }

    final credential = await _auth.register(
      email: normalizedEmail,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw StateError('Firebase did not return the newly created account.');
    }

    await firebaseUser.updateDisplayName(name.trim());
    await _users.create(
      AppUser(
        uid: firebaseUser.uid,
        name: name.trim(),
        email: normalizedEmail,
        role: 'student',
      ),
    );
    await _verification.send(firebaseUser);
  }

  Future<AppUser?> login(String email, String password) async {
    await _auth.login(email, password);
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw StateError('Firebase did not return the signed-in account.');
    }

    await firebaseUser.reload();
    final refreshedUser = _auth.currentUser;
    if (refreshedUser == null || !refreshedUser.emailVerified) {
      await _auth.logout();
      throw StateError('Verify your ALU email address before signing in.');
    }

    final profile = await loadProfile(refreshedUser.uid);
    if (profile == null) {
      throw StateError('Your account profile is missing. Contact the project administrator.');
    }
    return profile;
  }

  Future<void> resendVerification() => _auth.sendVerificationEmail();

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
