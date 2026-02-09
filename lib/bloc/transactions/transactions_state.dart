import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/models/transaction_model.dart';
import '../../domain/transactions/transaction_aggregations.dart';

enum TransactionsStatus { initial, loading, ready, failure }

class TransactionsState extends Equatable {
  const TransactionsState({
    required this.transactions,
    required this.filter,
    required this.status,
    required this.dateRange,
    required this.displayBalance,
    this.errorMessage,
  });

  final List<TransactionModel> transactions;
  final TransactionFilter filter;
  final TransactionsStatus status;
  final DateTimeRange? dateRange;
  final double displayBalance;
  final String? errorMessage;

  factory TransactionsState.initial() {
    return const TransactionsState(
      transactions: [],
      filter: TransactionFilter.all,
      status: TransactionsStatus.initial,
      dateRange: null,
      displayBalance: 0,
    );
  }

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    TransactionFilter? filter,
    TransactionsStatus? status,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    double? displayBalance,
    String? errorMessage,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      status: status ?? this.status,
      dateRange: clearDateRange ? null : dateRange ?? this.dateRange,
      displayBalance: displayBalance ?? this.displayBalance,
      errorMessage: errorMessage,
    );
  }

  double get balance {
    return transactions.fold<double>(
      0,
      (total, transaction) {
        final signed = transaction.type == TransactionType.income
            ? transaction.amount
            : -transaction.amount;
        return total + signed;
      },
    );
  }

  List<TransactionModel> get filteredTransactions {
    final inRange = _applyDateRange(transactions);
    return switch (filter) {
      TransactionFilter.income =>
        inRange.where((t) => t.type == TransactionType.income).toList(),
      TransactionFilter.expense =>
        inRange.where((t) => t.type == TransactionType.expense).toList(),
      TransactionFilter.all => inRange,
    };
  }

  List<TransactionGroup> get groupedTransactions {
    return TransactionAggregations.groupByDate(filteredTransactions);
  }

  List<CategoryTotal> get expenseCategoryTotals {
    final inRange = _applyDateRange(transactions);
    return TransactionAggregations.totalsByCategory(
      inRange,
      type: TransactionType.expense,
    );
  }

  List<TransactionModel> _applyDateRange(List<TransactionModel> input) {
    final range = dateRange;
    if (range == null) {
      return input;
    }
    // Normalize range boundaries so comparison ignores time-of-day.
    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
      23,
      59,
      59,
      999,
    );
    return input
        .where((transaction) =>
            !transaction.date.isBefore(start) &&
            !transaction.date.isAfter(end))
        .toList();
  }

  @override
  List<Object?> get props =>
      [transactions, filter, status, dateRange, displayBalance, errorMessage];
}
