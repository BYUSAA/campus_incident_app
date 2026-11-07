import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository.createDefault() {
    _authSubscription = _repository.authStateChanges.listen(
      _handleAuthStateChanged,
      onError: (Object error) {
        _profileError = 'Could not resolve the signed-in account: $error';
        _isInitialized = true;
        notifyListeners();
      },
    );
  }

  final AuthRepository _repository;
  StreamSubscription<User?>? _authSubscription;

  AppUser? _user;
  User? _firebaseUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String? _profileError;
  int _authStateVersion = 0;

  AppUser? get user => _user;
  User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;
  bool get isAuthenticated =>
      _firebaseUser != null && isEmailVerified && _user != null;
  String? get errorMessage => _errorMessage;
  String? get profileError => _profileError;
  bool get hasProfileError => _profileError != null;

  Future<void> _handleAuthStateChanged(User? firebaseUser) async {
    final version = ++_authStateVersion;
    _firebaseUser = firebaseUser;
    _profileError = null;

    if (firebaseUser == null) {
      _user = null;
      _isInitialized = true;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isInitialized = false;
    _user = null;
    notifyListeners();

    try {
      final profile = await _repository.loadProfile(firebaseUser.uid);
      if (version != _authStateVersion) return;
      _user = profile;
      if (profile == null) {
        _profileError =
            'Your Firebase account exists, but its campus profile is missing. '
            'Ask the project administrator to restore the users/${firebaseUser.uid} record.';
      }
      _errorMessage = null;
    } catch (error) {
      if (version != _authStateVersion) return;
      _user = null;
      _profileError =
          'The application could not load your Firebase profile. Check your connection and retry. $error';
    } finally {
      if (version == _authStateVersion) {
        _isInitialized = true;
        notifyListeners();
      }
    }
  }

  Future<void> login(String email, String password) async {
    await _runLoading(() async {
      _user = await _repository.login(email, password);
      _firebaseUser = _repository.currentUser;
      _profileError = null;
    });
  }

  Future<void> register(String name, String email, String password) async {
    await _runLoading(() async {
      await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      _firebaseUser = _repository.currentUser;
      if (_firebaseUser != null) {
        _user = await _repository.loadProfile(_firebaseUser!.uid);
        if (_user == null) {
          throw StateError(
            'Your account was created, but its profile could not be loaded. '
            'Please contact the project administrator.',
          );
        }
      }
    });
  }

  Future<bool> refreshVerification() async {
    final version = ++_authStateVersion;
    final verified = await _repository.refreshVerification();
    if (version != _authStateVersion) return false;
    _firebaseUser = _repository.currentUser;
    if (verified && _firebaseUser != null) {
      _isInitialized = false;
      notifyListeners();
      try {
        _user = await _repository.loadProfile(_firebaseUser!.uid);
        _profileError = _user == null
            ? 'Your Firebase user exists, but the campus profile is missing. Contact the administrator.'
            : null;
      } catch (error) {
        _user = null;
        _profileError = 'Email is verified, but the profile could not be loaded: $error';
      } finally {
        if (version == _authStateVersion) {
          _isInitialized = true;
          notifyListeners();
        }
      }
    } else {
      notifyListeners();
    }
    return verified;
  }

  Future<void> resendVerification() => _repository.resendVerification();

  Future<void> logout() async {
    await _repository.logout();
    ++_authStateVersion;
    _firebaseUser = null;
    _user = null;
    _profileError = null;
    _errorMessage = null;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final version = ++_authStateVersion;
    final current = _repository.currentUser;
    _firebaseUser = current;
    _profileError = null;
    if (current == null) {
      _user = null;
      _isInitialized = true;
      notifyListeners();
      return;
    }

    _isInitialized = false;
    notifyListeners();
    try {
      _user = await _repository.loadProfile(current.uid);
      if (_user == null) {
        _profileError =
            'Your profile record is missing. Ask an administrator to restore your account role.';
      }
    } catch (error) {
      _user = null;
      _profileError = 'Could not load your profile: $error';
    } finally {
      if (version == _authStateVersion) {
        _isInitialized = true;
        notifyListeners();
      }
    }
  }

  Future<void> _runLoading(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    ++_authStateVersion;
    _authSubscription?.cancel();
    super.dispose();
  }
}