class AppUser {
  const AppUser({required this.uid, required this.name, required this.email, this.role='student', this.emailVerified=false});
  final String uid, name, email, role;
  final bool emailVerified;
  bool get isStaff => role == 'staff';
  factory AppUser.fromMap(String uid, Map<String,dynamic> m) => AppUser(uid:uid,name:m['name'] as String? ?? '',email:m['email'] as String? ?? '',role:m['role'] as String? ?? 'student',emailVerified:m['emailVerified'] as bool? ?? false);
  Map<String,dynamic> toMap() => {'name':name,'email':email,'role':role,'emailVerified':emailVerified};
}
