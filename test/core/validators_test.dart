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

    test('accepts a valid name within the profile limit', () {
      expect(Validators.validateName('Byusa Martin'), isNull);
    });

    test('rejects a blank or overlong name', () {
      expect(Validators.validateName(' '), 'Name is required');
      final name = List<String>.filled(81, 'n').join();
      expect(Validators.validateName(name), contains('80 characters'));
    });

    test('rejects malformed ALU email values', () {
      expect(Validators.validateEmail('not-an-email@alustudent.com'), 'Enter a valid email address');
      expect(Validators.validateEmail('student @alustudent.com'), 'Enter a valid email address');
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
      final overlongTitle = List<String>.filled(101, 't').join();
      final overlongDescription = List<String>.filled(1001, 'd').join();
      final overlongLocation = List<String>.filled(161, 'l').join();

      expect(Validators.validateTitle(overlongTitle), contains('100 characters'));
      expect(
        Validators.validateDescription(overlongDescription),
        contains('1000 characters'),
      );
      expect(
        Validators.validateLocation(overlongLocation),
        contains('160 characters'),
      );
    });
  });
}