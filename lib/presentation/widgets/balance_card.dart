import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:tracker/core/localization/app_localizations.dart';
import 'package:tracker/core/theme/app_tokens.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final theme = Theme.of(context);
    final color = isPositive
        ? theme.semanticColors.income
        : theme.semanticColors.expense;
    final amountStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      color: color,
      fontWeight: FontWeight.bold,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.currentBalance, style: theme.textTheme.labelLarge),
          const SizedBox(height: 12),
          AnimatedFlipCounter(
            value: balance.abs(),
            fractionDigits: 2,
            prefix: '${isPositive ? '+' : '-'}€',
            duration: const Duration(milliseconds: 700),
            curve: Curves.linear,
            wholeDigits: 7,
            hideLeadingZeroes: true,
            textStyle: amountStyle,
          ),
        ],
      ),
    );
  }
}
