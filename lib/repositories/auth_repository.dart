import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';
import '../models/app_user.dart';
import '../services/email_verification_service.dart';
import '../services/firebase_auth_service.dart';
import 'user_repository.dart';
class AuthRepository {
  AuthRepository(this._auth,this._users,this._verification);
  final FirebaseAuthService _auth; final UserRepository _users; final EmailVerificationService _verification;
  User? get currentUser=>_auth.currentUser;
  Stream<User?> get authStateChanges=>_auth.authStateChanges;
  Future<void> register({required String name,required String email,required String password}) async {
    final normalized=email.trim().toLowerCase();
    if(!normalized.endsWith(AppConstants.aluStudentDomain)) throw Exception('Please use your ALU student email.');
    final cred=await _auth.register(normalized,password); final user=cred.user;
    if(user==null) throw Exception('Could not create user.');
    await _users.create(AppUser(uid:user.uid,name:name.trim(),email:normalized,role:'student'));
    await _verification.send(user);
  }
  Future<void> login(String email,String password) async {
    await _auth.login(email,password); final user=_auth.currentUser;
    if(user==null) throw Exception('Could not load user.');
    await user.reload();
    if(!(_auth.currentUser?.emailVerified ?? false)){await _auth.logout();throw Exception('Verify your email before signing in.');}
  }
  Future<void> resendVerification()=>_auth.sendVerificationEmail();
  Future<void> refreshUser()=>_auth.reloadUser();
  Future<void> logout()=>_auth.logout();
  Future<AppUser?> loadProfile(String uid)=>_users.getById(uid);
}
