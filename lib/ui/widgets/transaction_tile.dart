import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../core/formatters.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final TransactionModel transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountText = AppFormatters.signedCurrency(
      isIncome ? transaction.amount : -transaction.amount,
    );
    final color = isIncome ? Colors.green : Colors.red;

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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
