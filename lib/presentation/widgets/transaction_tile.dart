import 'package:flutter/material.dart';
import 'package:tracker/core/helpers/app_formatters.dart';
import 'package:tracker/core/theme/app_tokens.dart';
import 'package:tracker/domain/entities/transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, this.onTap});

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountText = AppFormatters.signedCurrency(
      isIncome ? transaction.amount : -transaction.amount,
    );
    final theme = Theme.of(context);
    final color = isIncome
        ? theme.semanticColors.income
        : theme.semanticColors.expense;

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(transaction.category),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppFormatters.shortDate(transaction.date)),
            if (transaction.note != null && transaction.note!.isNotEmpty)
              Text(
                transaction.note!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Text(
          amountText,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
