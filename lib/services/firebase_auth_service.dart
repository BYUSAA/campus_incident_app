import 'package:firebase_auth/firebase_auth.dart';
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth}):_auth=auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;
  User? get currentUser=>_auth.currentUser;
  Stream<User?> get authStateChanges=>_auth.authStateChanges();
  Future<UserCredential> register(String email,String password)=>_auth.createUserWithEmailAndPassword(email:email.trim(),password:password);
  Future<UserCredential> login(String email,String password)=>_auth.signInWithEmailAndPassword(email:email.trim(),password:password);
  Future<void> logout()=>_auth.signOut();
  Future<void> reloadUser() async { await _auth.currentUser?.reload(); }
  Future<void> sendVerificationEmail() async { final u=_auth.currentUser; if(u!=null && !u.emailVerified) await u.sendEmailVerification(); }
}
