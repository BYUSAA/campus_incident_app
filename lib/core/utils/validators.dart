import '../constants/app_constants.dart';
class Validators {
  Validators._();
  static String? required(String? v, {String label='This field'}) => v == null || v.trim().isEmpty ? '$label is required.' : null;
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required.';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()) ? null : 'Enter a valid email.';
  }
  static String? aluEmail(String? v) {
    final error=email(v); if (error != null) return error;
    return v!.trim().toLowerCase().endsWith(AppConstants.aluStudentDomain) ? null : 'Use your ALU student email (${AppConstants.aluStudentDomain}).';
  }
  static String? password(String? v) => v == null || v.isEmpty ? 'Password is required.' : v.length < 8 ? 'Use at least 8 characters.' : null;
}
