
import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/models/transaction_model.dart';

class TransactionFiltersRow extends StatelessWidget {
  const TransactionFiltersRow({
    super.key,
    required this.filter,
    required this.range,
    required this.onFilterChanged,
    required this.onRangeChanged,
  });

  final TransactionFilter filter;
  final DateTimeRange? range;
  final ValueChanged<TransactionFilter> onFilterChanged;
  final ValueChanged<DateTimeRange?> onRangeChanged;

  Future<void> _openDateSheet(BuildContext context) async {
    final now = DateTime.now();
    DateTime? start = range?.start;
    DateTime? end = range?.end;

    DateTimeRange? safeRange() {
      if (start == null || end == null) return null;
      if (start!.isAfter(end!)) {
        return DateTimeRange(start: end!, end: start!);
      }
      return DateTimeRange(start: start!, end: end!);
    }

    DateTime lastDayOfMonth(int year, int month) {
      final firstOfNextMonth =
      month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
      return firstOfNextMonth.subtract(const Duration(days: 1));
    }

    DateTime addMonths(DateTime date, int months) {
      // DateTime handles month overflow, which keeps the math stable across years.
      final targetMonth = DateTime(date.year, date.month + months, 1);
      final lastDay = lastDayOfMonth(targetMonth.year, targetMonth.month).day;
      final day = date.day > lastDay ? lastDay : date.day;
      return DateTime(targetMonth.year, targetMonth.month, day);
    }

    DateTimeRange lastMonthRange() {
      final lastMonth = addMonths(now, -1);
      final startDate = DateTime(lastMonth.year, lastMonth.month, 1);
      final endDate = lastDayOfMonth(lastMonth.year, lastMonth.month);
      return DateTimeRange(start: startDate, end: endDate);
    }

    DateTimeRange lastQuarterRange() {
      final lastMonth = addMonths(now, -1);
      final startMonth = addMonths(
        DateTime(lastMonth.year, lastMonth.month, 1),
        -2,
      );
      final startDate = DateTime(startMonth.year, startMonth.month, 1);
      final endDate = lastDayOfMonth(lastMonth.year, lastMonth.month);
      return DateTimeRange(start: startDate, end: endDate);
    }

    DateTimeRange lastYearRange() {
      final year = now.year - 1;
      return DateTimeRange(
        start: DateTime(year, 1, 1),
        end: DateTime(year, 12, 31),
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final sr = safeRange();
            final startLabel = start == null
                ? 'Select a date'
                : AppFormatters.shortDate(start!);
            final endLabel =
                end == null ? 'Select a date' : AppFormatters.shortDate(end!);

            bool matchesRange(DateTimeRange r) {
              final s = safeRange();
              if (s == null) return false;
              return s.start.year == r.start.year &&
                  s.start.month == r.start.month &&
                  s.start.day == r.start.day &&
                  s.end.year == r.end.year &&
                  s.end.month == r.end.month &&
                  s.end.day == r.end.day;
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select a date range',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (range != null)
                        TextButton(
                          onPressed: () {
                            onRangeChanged(null);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _RangeChip(
                        label: 'Last month',
                        selected: matchesRange(lastMonthRange()),
                        onTap: () {
                          final r = lastMonthRange();
                          setState(() {
                            start = r.start;
                            end = r.end;
                          });
                        },
                      ),
                      _RangeChip(
                        label: 'Last quarter',
                        selected: matchesRange(lastQuarterRange()),
                        onTap: () {
                          final r = lastQuarterRange();
                          setState(() {
                            start = r.start;
                            end = r.end;
                          });
                        },
                      ),
                      _RangeChip(
                        label: 'Last year',
                        selected: matchesRange(lastYearRange()),
                        onTap: () {
                          final r = lastYearRange();
                          setState(() {
                            start = r.start;
                            end = r.end;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Start'),
                    subtitle: Text(startLabel),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: start ?? now,
                        firstDate: DateTime(2015),
                        lastDate: DateTime(now.year + 5),
                      );
                      if (picked != null) {
                        setState(() {
                          start = picked;
                          if (end != null && end!.isBefore(start!)) {
                            end = start;
                          }
                        });
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('End'),
                    subtitle: Text(endLabel),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: end ?? start ?? now,
                        firstDate: DateTime(2015),
                        lastDate: DateTime(now.year + 5),
                      );
                      if (picked != null) {
                        setState(() {
                          end = picked;
                          if (start == null || end!.isBefore(start!)) {
                            start = end;
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: safeRange() != null
                          ? () {
                        onRangeChanged(safeRange());
                        Navigator.of(context).pop();
                      }
                          : null,
                      child: const Text('Show activities'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _toggleFilter(TransactionFilter target) {
    if (filter == target) {
      onFilterChanged(TransactionFilter.all);
    } else {
      onFilterChanged(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = range == null
        ? 'All dates'
        : '${AppFormatters.shortDate(range!.start)} - ${AppFormatters.shortDate(range!.end)}';

    final isExpense = filter == TransactionFilter.expense;
    final isIncome = filter == TransactionFilter.income;
    final selectedColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: label,
            selected: range != null,
            selectedColor: selectedColor,
            onTap: () => _openDateSheet(context),
            onClear: range == null ? null : () => onRangeChanged(null),
            leading: const Icon(Icons.date_range, size: 18),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Expenses',
            selected: isExpense,
            selectedColor: selectedColor,
            onTap: () => _toggleFilter(TransactionFilter.expense),
            onClear: isExpense ? () => onFilterChanged(TransactionFilter.all) : null,
            leading: const Icon(Icons.remove_circle_outline_rounded, size: 18),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Income',
            selected: isIncome,
            selectedColor: selectedColor,
            onTap: () => _toggleFilter(TransactionFilter.income),
            onClear: isIncome ? () => onFilterChanged(TransactionFilter.all) : null,
            leading: const Icon(Icons.add_circle_outline_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
    this.onClear,
    this.leading,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final borderColor = selected ? selectedColor : Theme.of(context).colorScheme.outlineVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              IconTheme(
                data: IconThemeData(color: textColor, size: 18),
                child: leading!,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 6),
              InkWell(
                onTap: onClear,
                child: Icon(Icons.close, size: 16, color: textColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final textColor = selected ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final borderColor = selected ? color : Theme.of(context).colorScheme.outlineVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
