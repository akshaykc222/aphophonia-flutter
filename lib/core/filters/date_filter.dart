import 'package:intl/intl.dart';

enum DateFilterMode { singleDay, range }

/// Local-calendar filter for `published_at` (and CAPT fallback dates).
class DateFilter {
  const DateFilter({
    required this.mode,
    required this.startDay,
    this.endDay,
  });

  final DateFilterMode mode;
  /// First day included (local date, time ignored).
  final DateTime startDay;
  /// Last day included for [DateFilterMode.range].
  final DateTime? endDay;

  factory DateFilter.singleDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return DateFilter(mode: DateFilterMode.singleDay, startDay: d);
  }

  factory DateFilter.range(DateTime from, DateTime to) {
    final a = DateTime(from.year, from.month, from.day);
    final b = DateTime(to.year, to.month, to.day);
    if (b.isBefore(a)) {
      return DateFilter(
        mode: DateFilterMode.range,
        startDay: b,
        endDay: a,
      );
    }
    return DateFilter(mode: DateFilterMode.range, startDay: a, endDay: b);
  }

  DateTime get rangeStartLocal =>
      DateTime(startDay.year, startDay.month, startDay.day);

  DateTime get rangeEndLocal {
    final end = endDay ?? startDay;
    return DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
  }

  String get startIsoUtc => rangeStartLocal.toUtc().toIso8601String();

  String get endIsoUtc => rangeEndLocal.toUtc().toIso8601String();

  bool contains(DateTime dateTime) {
    final local = dateTime.toLocal();
    return !local.isBefore(rangeStartLocal) && !local.isAfter(rangeEndLocal);
  }

  String label({String locale = 'ar'}) {
    final fmt = DateFormat('d MMM yyyy', locale);
    final end = endDay;
    if (mode == DateFilterMode.singleDay || end == null) {
      return fmt.format(startDay);
    }
    if (startDay.year == end.year &&
        startDay.month == end.month &&
        startDay.day == end.day) {
      return fmt.format(startDay);
    }
    return '${fmt.format(startDay)} — ${fmt.format(end)}';
  }
}
