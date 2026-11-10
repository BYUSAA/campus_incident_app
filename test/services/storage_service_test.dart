import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/services/storage_service.dart';

void main() {
  test('StorageService does not initialize Firebase Storage eagerly', () {
    expect(() => StorageService(), returnsNormally);
  });
}
