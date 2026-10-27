import 'package:intl/intl.dart';
class DateFormatter {
  DateFormatter._();
  static String format(DateTime? date) => date == null ? 'Just now' : DateFormat('d MMM yyyy, HH:mm').format(date.toLocal());
}
