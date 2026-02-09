import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/transactions/transaction_aggregations.dart';
import 'transaction_tile.dart';

class GroupedTransactionList extends StatelessWidget {
  const GroupedTransactionList({
    super.key,
    required this.groups,
    required this.onDelete,
    required this.onEdit,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 12),
  });

  final List<TransactionGroup> groups;
  final ValueChanged<TransactionModel> onDelete;
  final ValueChanged<TransactionModel> onEdit;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final items = _flatten(groups);
    return SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            if (item is _GroupHeaderItem) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DateHeader(date: item.date),
              );
            }

            final txItem = item as _TransactionItem;
            final spacing = txItem.isLastInGroup ? 16.0 : 8.0;
            return Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: Dismissible(
                key: ValueKey(txItem.transaction.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => onDelete(txItem.transaction),
                child: TransactionTile(
                  transaction: txItem.transaction,
                  onTap: () => onEdit(txItem.transaction),
                ),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  List<_GroupedListItem> _flatten(List<TransactionGroup> groups) {
    final items = <_GroupedListItem>[];
    for (final group in groups) {
      items.add(_GroupHeaderItem(group.date));
      for (var i = 0; i < group.transactions.length; i++) {
        items.add(
          _TransactionItem(
            group.transactions[i],
            isLastInGroup: i == group.transactions.length - 1,
          ),
        );
      }
    }
    return items;
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppFormatters.longDate(date),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

sealed class _GroupedListItem {
  const _GroupedListItem();
}

class _GroupHeaderItem extends _GroupedListItem {
  const _GroupHeaderItem(this.date);

  final DateTime date;
}

class _TransactionItem extends _GroupedListItem {
  const _TransactionItem(
    this.transaction, {
    required this.isLastInGroup,
  });

  final TransactionModel transaction;
  final bool isLastInGroup;
}
