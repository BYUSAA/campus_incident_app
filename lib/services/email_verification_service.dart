import 'package:firebase_auth/firebase_auth.dart';
class EmailVerificationService {
  Future<void> send(User user) async {if(!user.emailVerified) await user.sendEmailVerification();}
  Future<bool> refreshAndCheck(User user) async {await user.reload();return FirebaseAuth.instance.currentUser?.emailVerified ?? false;}
}
