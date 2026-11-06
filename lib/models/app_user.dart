class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student' or 'staff'

  AppUser({required this.uid, required this.name, required this.email, required this.role});

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        role: map['role'] ?? 'student',
      );
}