import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker/core/localization/app_localizations.dart';
import 'package:tracker/presentation/states/cubits/transactions/transactions_cubit.dart';
import 'package:tracker/presentation/states/cubits/transactions/transactions_state.dart';
import 'package:tracker/presentation/views/add_edit_transaction_page.dart';
import 'package:tracker/presentation/widgets/balance_card.dart';
import 'package:tracker/presentation/widgets/category_spending_chart.dart';
import 'package:tracker/presentation/widgets/common/app_slivers.dart';
import 'package:tracker/presentation/widgets/demo_button.dart';
import 'package:tracker/presentation/widgets/empty_state.dart';
import 'package:tracker/presentation/widgets/error_state.dart';
import 'package:tracker/presentation/widgets/grouped_transaction_list.dart';
import 'package:tracker/presentation/widgets/language_button.dart';
import 'package:tracker/presentation/widgets/section_header.dart';
import 'package:tracker/presentation/widgets/theme_button.dart';
import 'package:tracker/presentation/widgets/transaction_filters_row.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.financeTracker),
        actions: const [DemoButton(), LanguageButton(), ThemeButton()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditTransactionPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(context.l10n.addTransaction),
      ),
      body: SafeArea(
        child: BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, state) {
            if (state.status == TransactionsStatus.loading &&
                state.transactions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == TransactionsStatus.failure) {
              return ErrorState(message: state.errorMessage);
            }

            final transactions = state.filteredTransactions;
            final groupedTransactions = state.groupedTransactions;
            final categoryTotals = state.expenseCategoryTotals;
            final cubit = context.read<TransactionsCubit>();

            return RefreshIndicator(
              onRefresh: cubit.load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const AppSliverGap(12),
                  AppSliverBox(child: BalanceCard(balance: state.balance)),
                  const AppSliverGap(20),
                  AppSliverBox(
                    child: SectionHeader(
                      title: context.l10n.spendingByCategory,
                    ),
                  ),
                  const AppSliverGap(8),
                  AppSliverBox(
                    child: CategorySpendingChart(categories: categoryTotals),
                  ),
                  const AppSliverGap(20),
                  AppSliverBox(
                    child: SectionHeader(title: context.l10n.transactions),
                  ),
                  const AppSliverGap(8),
                  AppSliverBox(
                    child: TransactionFiltersRow(
                      filter: state.filter,
                      range: state.dateRange,
                      onFilterChanged: cubit.toggleFilter,
                      onRangeChanged: cubit.setDateRange,
                    ),
                  ),
                  const AppSliverGap(12),
                  if (transactions.isEmpty)
                    const AppSliverBox(child: EmptyState())
                  else
                    GroupedTransactionList(
                      groups: groupedTransactions,
                      onDelete: (transaction) =>
                          cubit.deleteTransaction(transaction.id),
                      onEdit: (transaction) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditTransactionPage(initial: transaction),
                          ),
                        );
                      },
                    ),
                  const AppSliverGap(24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
