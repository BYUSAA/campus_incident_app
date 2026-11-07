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
      expect(
        Validators.validatePassword('123'),
        'Password must be at least 6 characters',
      );
    });

    test('accepts incident field values within the limits', () {
      expect(Validators.validateTitle('Broken classroom projector'), isNull);
      expect(Validators.validateDescription('A detailed report.'), isNull);
      expect(Validators.validateLocation('Block B, Room 204'), isNull);
    });

    test('rejects incident field values longer than backend limits', () {
      expect(Validators.validateTitle('t' * 101), contains('100 characters'));
      expect(
        Validators.validateDescription('d' * 1001),
        contains('1000 characters'),
      );
      expect(
        Validators.validateLocation('l' * 161),
        contains('160 characters'),
      );
    });
  });
}