import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register
  Future<AppUser> signUp(String email, String password, String name) async {
    if (!email.endsWith('@alustudent.com') && !email.endsWith('@alueducation.com')) {
      throw Exception('Please use a valid ALU email address.');
    }
    
    UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    
    AppUser user = AppUser(
      uid: cred.user!.uid,
      name: name,
      email: email,
      role: 'student', // Default role
    );

    await _firestore.collection('users').doc(cred.user!.uid).set(user.toMap());
    await cred.user!.sendEmailVerification();
    return user;
  }

  // Login
  Future<AppUser?> signIn(String email, String password) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (!cred.user!.emailVerified) {
      throw Exception('Please verify your email first.');
    }
    
    DocumentSnapshot doc = await _firestore.collection('users').doc(cred.user!.uid).get();
    return AppUser.fromMap(doc.data() as Map<String, dynamic>);
  }

  // Logout
  Future<void> signOut() async => await _auth.signOut();
}