import 'package:intl/intl.dart';

abstract final class ReportDates {
  /// "Just now", "5m ago", "3h ago", "2d ago", then the calendar date.
  static String relative(DateTime moment, {DateTime? now}) {
    final elapsed = (now ?? DateTime.now()).difference(moment);
    if (elapsed.inMinutes < 1) return 'Just now';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes}m ago';
    if (elapsed.inDays < 1) return '${elapsed.inHours}h ago';
    if (elapsed.inDays < 7) return '${elapsed.inDays}d ago';
    return DateFormat.yMMMd().format(moment);
  }

  static String full(DateTime moment) =>
      DateFormat.yMMMd().add_jm().format(moment);

  static String day(DateTime moment) => DateFormat.yMMMd().format(moment);
}
