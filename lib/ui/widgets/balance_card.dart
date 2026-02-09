import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final amountStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: Theme.of(context).textTheme.labelLarge,
          ),
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
