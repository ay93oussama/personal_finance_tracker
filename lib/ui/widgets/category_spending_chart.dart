import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../domain/transactions/transaction_aggregations.dart';

class CategorySpendingChart extends StatefulWidget {
  const CategorySpendingChart({
    super.key,
    required this.categories,
  });

  final List<CategoryTotal> categories;

  @override
  State<CategorySpendingChart> createState() => _CategorySpendingChartState();
}

class _CategorySpendingChartState extends State<CategorySpendingChart> {
  static const int _previewCount = 3;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories;
    if (categories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
        child: Text(
          'No expenses yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    final totalExpenses = categories.fold<double>(
      0,
      (sum, entry) => sum + entry.total,
    );
    final visibleCategories = _expanded || categories.length <= _previewCount
        ? categories
        : categories.take(_previewCount).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in visibleCategories) ...[
            _CategoryBar(
              entry: entry,
              totalExpenses: totalExpenses,
            ),
            if (entry != visibleCategories.last) const SizedBox(height: 12),
          ],
          if (categories.length > _previewCount) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Text(_expanded ? 'Show less' : 'Show more'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Bars show each category as a share of total expenses '
            'for the selected date range.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.entry,
    required this.totalExpenses,
  });

  final CategoryTotal entry;
  final double totalExpenses;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final background = Theme.of(context).colorScheme.surfaceContainerHighest;
    final fraction = totalExpenses == 0 ? 0.0 : entry.total / totalExpenses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                entry.category,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppFormatters.currency(entry.total),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            FractionallySizedBox(
              widthFactor: fraction,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
