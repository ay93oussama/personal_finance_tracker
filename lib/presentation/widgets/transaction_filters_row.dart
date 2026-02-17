import 'package:flutter/material.dart';
import 'package:tracker/core/helpers/app_formatters.dart';
import 'package:tracker/core/localization/app_localizations.dart';
import 'package:tracker/domain/entities/transaction_filter.dart';
import 'package:tracker/domain/usecases/transactions/transaction_date_range_presets.dart';

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
            final safeRange = TransactionDateRangePresets.normalize(start, end);
            final lastMonthRange = TransactionDateRangePresets.lastMonth(now);
            final lastQuarterRange = TransactionDateRangePresets.lastQuarter(
              now,
            );
            final lastYearRange = TransactionDateRangePresets.lastYear(now);
            final startLabel = start == null
                ? context.l10n.selectDate
                : AppFormatters.shortDate(start!);
            final endLabel = end == null
                ? context.l10n.selectDate
                : AppFormatters.shortDate(end!);

            bool matchesRange(DateTimeRange r) {
              if (safeRange == null) {
                return false;
              }
              return TransactionDateRangePresets.sameDay(
                    safeRange.start,
                    r.start,
                  ) &&
                  TransactionDateRangePresets.sameDay(safeRange.end, r.end);
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
                        context.l10n.selectDateRange,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (range != null)
                        TextButton(
                          onPressed: () {
                            onRangeChanged(null);
                            Navigator.of(context).pop();
                          },
                          child: Text(context.l10n.clear),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _RangeChip(
                        label: context.l10n.lastMonth,
                        selected: matchesRange(lastMonthRange),
                        onTap: () {
                          setState(() {
                            start = lastMonthRange.start;
                            end = lastMonthRange.end;
                          });
                        },
                      ),
                      _RangeChip(
                        label: context.l10n.lastQuarter,
                        selected: matchesRange(lastQuarterRange),
                        onTap: () {
                          setState(() {
                            start = lastQuarterRange.start;
                            end = lastQuarterRange.end;
                          });
                        },
                      ),
                      _RangeChip(
                        label: context.l10n.lastYear,
                        selected: matchesRange(lastYearRange),
                        onTap: () {
                          setState(() {
                            start = lastYearRange.start;
                            end = lastYearRange.end;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.start),
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
                    title: Text(context.l10n.end),
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
                      onPressed: safeRange != null
                          ? () {
                              onRangeChanged(safeRange);
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text(context.l10n.showActivities),
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

  @override
  Widget build(BuildContext context) {
    final label = range == null
        ? context.l10n.allDates
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
            label: context.l10n.expenses,
            selected: isExpense,
            selectedColor: selectedColor,
            onTap: () => onFilterChanged(TransactionFilter.expense),
            onClear: isExpense
                ? () => onFilterChanged(TransactionFilter.all)
                : null,
            leading: const Icon(Icons.remove_circle_outline_rounded, size: 18),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: context.l10n.income,
            selected: isIncome,
            selectedColor: selectedColor,
            onTap: () => onFilterChanged(TransactionFilter.income),
            onClear: isIncome
                ? () => onFilterChanged(TransactionFilter.all)
                : null,
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
    final textColor = selected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final borderColor = selected
        ? selectedColor
        : Theme.of(context).colorScheme.outlineVariant;

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
    final textColor = selected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final borderColor = selected
        ? color
        : Theme.of(context).colorScheme.outlineVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
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
