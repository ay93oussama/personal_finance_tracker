import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/domain/usecases/transactions/transaction_date_range_presets.dart';

void main() {
  test('lastMonth returns full previous month boundaries', () {
    final range = TransactionDateRangePresets.lastMonth(DateTime(2024, 3, 15));

    expect(range.start, DateTime(2024, 2, 1));
    expect(range.end, DateTime(2024, 2, 29));
  });

  test('lastQuarter returns three full months before current month', () {
    final range = TransactionDateRangePresets.lastQuarter(
      DateTime(2024, 3, 15),
    );

    expect(range.start, DateTime(2023, 12, 1));
    expect(range.end, DateTime(2024, 2, 29));
  });

  test('lastYear returns the full previous year', () {
    final range = TransactionDateRangePresets.lastYear(DateTime(2026, 7, 3));

    expect(range.start, DateTime(2025, 1, 1));
    expect(range.end, DateTime(2025, 12, 31));
  });

  test('normalize swaps start and end when needed', () {
    final range = TransactionDateRangePresets.normalize(
      DateTime(2024, 3, 10),
      DateTime(2024, 3, 1),
    );

    expect(range, isA<DateTimeRange>());
    expect(range!.start, DateTime(2024, 3, 1));
    expect(range.end, DateTime(2024, 3, 10));
  });
}
