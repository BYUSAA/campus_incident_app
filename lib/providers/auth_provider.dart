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
        _errorMessage = error.toString();
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

  AppUser? get user => _user;
  User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;
  bool get isAuthenticated => _firebaseUser != null && isEmailVerified;
  String? get errorMessage => _errorMessage;

  Future<void> _handleAuthStateChanged(User? firebaseUser) async {
    _firebaseUser = firebaseUser;
    if (firebaseUser == null) {
      _user = null;
      _isInitialized = true;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    try {
      _user = await _repository.loadProfile(firebaseUser.uid);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    await _runLoading(() async {
      _user = await _repository.login(email, password);
      _firebaseUser = _repository.currentUser;
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
      }
    });
  }

  Future<bool> refreshVerification() async {
    final verified = await _repository.refreshVerification();
    _firebaseUser = _repository.currentUser;
    if (verified && _firebaseUser != null) {
      _user = await _repository.loadProfile(_firebaseUser!.uid);
    }
    notifyListeners();
    return verified;
  }

  Future<void> resendVerification() => _repository.resendVerification();

  Future<void> logout() async {
    await _repository.logout();
    _firebaseUser = null;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final current = _repository.currentUser;
    _firebaseUser = current;
    if (current == null) {
      _user = null;
    } else {
      _user = await _repository.loadProfile(current.uid);
    }
    notifyListeners();
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
    _authSubscription?.cancel();
    super.dispose();
  }
}
