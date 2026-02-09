import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/theme/theme_cubit.dart';
import '../../bloc/transactions/transactions_cubit.dart';
import '../../bloc/transactions/transactions_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/category_spending_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/grouped_transaction_list.dart';
import '../widgets/section_header.dart';
import '../widgets/transaction_filters_row.dart';
import 'add_edit_transaction_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        actions: [
          BlocBuilder<TransactionsCubit, TransactionsState>(
            builder: (context, state) {
              if (state.transactions.isNotEmpty) {
                return const SizedBox.shrink();
              }
              return OutlinedButton(
                onPressed: () =>
                    context.read<TransactionsCubit>().addDemoTransactions(),
                child: const Text('Demo'),
              );
            },
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final icon =
                  mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode;
              return IconButton(
                tooltip: 'Toggle theme',
                onPressed: () => context.read<ThemeCubit>().toggle(),
                icon: Icon(icon),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditTransactionPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add transaction'),
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

            return RefreshIndicator(
              onRefresh: () => context.read<TransactionsCubit>().load(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                    child: BalanceCard(balance: state.displayBalance),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(title: 'Spending by category'),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: CategorySpendingChart(categories: categoryTotals),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(title: 'Transactions'),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: TransactionFiltersRow(
                        filter: state.filter,
                        range: state.dateRange,
                        onFilterChanged: (filter) =>
                            context.read<TransactionsCubit>().setFilter(filter),
                        onRangeChanged: (range) =>
                            context.read<TransactionsCubit>().setDateRange(range),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (transactions.isEmpty)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(child: EmptyState()),
                    )
                  else
                    GroupedTransactionList(
                      groups: groupedTransactions,
                      onDelete: (transaction) => context
                          .read<TransactionsCubit>()
                          .deleteTransaction(transaction.id),
                      onEdit: (transaction) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddEditTransactionPage(
                              initial: transaction,
                            ),
                          ),
                        );
                      },
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
