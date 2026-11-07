import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/core/constants/incident_status.dart';

void main() {
  group('IncidentStatus', () {
    test('allows only the next forward status', () {
      expect(
        IncidentStatus.optionsFor(IncidentStatus.submitted),
        [IncidentStatus.submitted, IncidentStatus.inProgress],
      );
      expect(
        IncidentStatus.optionsFor(IncidentStatus.inProgress),
        [IncidentStatus.inProgress, IncidentStatus.resolved],
      );
      expect(
        IncidentStatus.optionsFor(IncidentStatus.resolved),
        [IncidentStatus.resolved],
      );
    });

    test('rejects backwards status transitions', () {
      expect(
        IncidentStatus.canTransition(
          IncidentStatus.inProgress,
          IncidentStatus.submitted,
        ),
        isFalse,
      );
      expect(
        IncidentStatus.canTransition(
          IncidentStatus.resolved,
          IncidentStatus.inProgress,
        ),
        isFalse,
      );
    });

    test('allows the current status to remain unchanged', () {
      expect(
        IncidentStatus.canTransition(
          IncidentStatus.submitted,
          IncidentStatus.submitted,
        ),
        isTrue,
      );
    });
  });
}
