import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('accepts an ALU student email', () {
      expect(Validators.validateEmail('student@alustudent.com'), isNull);
    });

    test('rejects a non-ALU email', () {
      expect(
        Validators.validateEmail('student@example.com'),
        'Use your @alustudent.com email address',
      );
    });

    test('rejects a blank required field', () {
      expect(Validators.validateRequired('  ', 'Title'), 'Title is required');
    });

    test('rejects a short password', () {
      expect(Validators.validatePassword('123'), 'Password must be at least 6 characters');
    });
  });
}
