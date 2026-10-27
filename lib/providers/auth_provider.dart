import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo); final AuthRepository _repo;
  StreamSubscription<User?>? _sub; User? _user; AppUser? _profile; bool _loading=false; String? _error;
  User? get firebaseUser=>_user; AppUser? get profile=>_profile; bool get isLoading=>_loading; String? get error=>_error;
  bool get isAuthenticated=>_user?.emailVerified ?? false; bool get isStaff=>_profile?.isStaff ?? false;
  void listenToAuthChanges(){_sub?.cancel();_sub=_repo.authStateChanges.listen((u) async {_user=u;_profile=u==null?null:await _repo.loadProfile(u.uid);notifyListeners();});}
  Future<bool> register(String n,String e,String p) async => await _run(() async {await _repo.register(name:n,email:e,password:p);return true;}) ?? false;
  Future<bool> login(String e,String p) async {final ok=await _run(() async {await _repo.login(e,p);_user=_repo.currentUser;if(_user!=null)_profile=await _repo.loadProfile(_user!.uid);return true;});return ok ?? false;}
  Future<void> resendVerification() async {await _run(() async {await _repo.resendVerification();return true;});}
  Future<bool> refreshVerification() async => await _run(() async {await _repo.refreshUser();_user=_repo.currentUser;if(_user!=null&&_user!.emailVerified)_profile=await _repo.loadProfile(_user!.uid);return _user?.emailVerified??false;}) ?? false;
  Future<void> logout() async {await _repo.logout();_user=null;_profile=null;notifyListeners();}
  Future<T?> _run<T>(Future<T> Function() action) async {_loading=true;_error=null;notifyListeners();try{return await action();}catch(e){_error=e.toString().replaceFirst('Exception: ','');return null;}finally{_loading=false;notifyListeners();}}
  @override void dispose(){_sub?.cancel();super.dispose();}
}
