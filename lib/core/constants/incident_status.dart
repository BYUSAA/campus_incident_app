/// Canonical incident status values and allowed staff progression.
abstract final class IncidentStatus {
  static const String submitted = 'Submitted';
  static const String inProgress = 'In Progress';
  static const String resolved = 'Resolved';

  static const List<String> values = [
    submitted,
    inProgress,
    resolved,
  ];

  static List<String> optionsFor(String currentStatus) {
    switch (currentStatus) {
      case submitted:
        return [submitted, inProgress];
      case inProgress:
        return [inProgress, resolved];
      case resolved:
        return [resolved];
      default:
        return [currentStatus];
    }
  }

  static bool canTransition(String from, String to) {
    return optionsFor(from).contains(to);
  }
}
