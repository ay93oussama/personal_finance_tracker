import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker/core/localization/app_localizations.dart';
import 'package:tracker/presentation/states/cubits/transactions/transactions_cubit.dart';
import 'package:tracker/presentation/states/cubits/transactions/transactions_state.dart';

class DemoButton extends StatelessWidget {
  const DemoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TransactionsCubit, TransactionsState, bool>(
      selector: (state) => state.transactions.isEmpty,
      builder: (context, shouldShow) {
        if (!shouldShow) return const SizedBox.shrink();
        return OutlinedButton(
          onPressed: () =>
              context.read<TransactionsCubit>().addDemoTransactions(),
          child: Text(context.l10n.demo),
        );
      },
    );
  }
}
