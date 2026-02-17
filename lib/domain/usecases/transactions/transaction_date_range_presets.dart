import 'package:flutter/material.dart';

class TransactionDateRangePresets {
  TransactionDateRangePresets._();

  static DateTimeRange? normalize(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return null;
    }
    if (start.isAfter(end)) {
      return DateTimeRange(start: end, end: start);
    }
    return DateTimeRange(start: start, end: end);
  }

  static DateTimeRange lastMonth(DateTime anchor) {
    final month = _addMonths(anchor, -1);
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = _lastDayOfMonth(month.year, month.month);
    return DateTimeRange(start: startDate, end: endDate);
  }

  static DateTimeRange lastQuarter(DateTime anchor) {
    final lastMonth = _addMonths(anchor, -1);
    final quarterStartMonth = _addMonths(
      DateTime(lastMonth.year, lastMonth.month, 1),
      -2,
    );
    final startDate = DateTime(
      quarterStartMonth.year,
      quarterStartMonth.month,
      1,
    );
    final endDate = _lastDayOfMonth(lastMonth.year, lastMonth.month);
    return DateTimeRange(start: startDate, end: endDate);
  }

  static DateTimeRange lastYear(DateTime anchor) {
    final year = anchor.year - 1;
    return DateTimeRange(
      start: DateTime(year, 1, 1),
      end: DateTime(year, 12, 31),
    );
  }

  static bool sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime _lastDayOfMonth(int year, int month) {
    final firstOfNextMonth = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    return firstOfNextMonth.subtract(const Duration(days: 1));
  }

  static DateTime _addMonths(DateTime date, int months) {
    final targetMonth = DateTime(date.year, date.month + months, 1);
    final lastDay = _lastDayOfMonth(targetMonth.year, targetMonth.month).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime(targetMonth.year, targetMonth.month, day);
  }
}
