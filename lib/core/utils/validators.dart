import '../constants/app_constants.dart';

class Validators {
  static String? validateEmail(String? value) {
    final email = value?.trim().toLowerCase() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (email.length > 254 ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    if (!email.endsWith(AppConstants.aluStudentDomain)) {
      return 'Use your @alustudent.com email address';
    }
    return null;
  }

  static String? validateName(String? value) =>
      _validateBoundedText(value, 'Name', 80);

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateTitle(String? value) =>
      _validateBoundedText(value, 'Title', 100);

  static String? validateDescription(String? value) =>
      _validateBoundedText(value, 'Description', 1000);

  static String? validateLocation(String? value) =>
      _validateBoundedText(value, 'Location', 160);

  static String? _validateBoundedText(
    String? value,
    String fieldName,
    int maximumLength,
  ) {
    final requiredError = validateRequired(value, fieldName);
    if (requiredError != null) return requiredError;

    if (value!.trim().length > maximumLength) {
      return '$fieldName must be $maximumLength characters or fewer';
    }
    return null;
  }
}
