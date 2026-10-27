import '../models/app_user.dart';
import '../services/firestore_service.dart';
class UserRepository {
  UserRepository(this._firestore);
  final FirestoreService _firestore;
  Future<void> create(AppUser user)=>_firestore.saveUser(user.uid,user.toMap());
  Future<AppUser?> getById(String uid) async {final d=await _firestore.getUser(uid);return d==null?null:AppUser.fromMap(uid,d);}
  Future<void> updateEmailVerification(String uid,bool value)=>_firestore.saveUser(uid,{'emailVerified':value});
}
