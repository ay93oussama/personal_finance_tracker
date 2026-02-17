import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:tracker/domain/entities/transaction.dart';
import 'package:tracker/domain/entities/transaction_filter.dart';
import 'package:tracker/domain/usecases/transactions/transaction_aggregations.dart';

enum TransactionsStatus { initial, loading, ready, failure }

class TransactionsState extends Equatable {
  const TransactionsState({
    required this.transactions,
    required this.filter,
    required this.status,
    required this.dateRange,
    this.errorMessage,
  });

  final List<Transaction> transactions;
  final TransactionFilter filter;
  final TransactionsStatus status;
  final DateTimeRange? dateRange;
  final String? errorMessage;

  factory TransactionsState.initial() {
    return const TransactionsState(
      transactions: [],
      filter: TransactionFilter.all,
      status: TransactionsStatus.initial,
      dateRange: null,
    );
  }

  TransactionsState copyWith({
    List<Transaction>? transactions,
    TransactionFilter? filter,
    TransactionsStatus? status,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    String? errorMessage,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      status: status ?? this.status,
      dateRange: clearDateRange ? null : dateRange ?? this.dateRange,
      errorMessage: errorMessage,
    );
  }

  double get balance => TransactionAggregations.netBalance(transactions);

  List<Transaction> get filteredTransactions {
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

  List<Transaction> _applyDateRange(List<Transaction> input) {
    final range = dateRange;
    if (range == null) {
      return input;
    }
    // Normalize range boundaries so comparison ignores time-of-day.
    final start = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
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
        .where(
          (transaction) =>
              !transaction.date.isBefore(start) &&
              !transaction.date.isAfter(end),
        )
        .toList();
  }

  @override
  List<Object?> get props => [
    transactions,
    filter,
    status,
    dateRange,
    errorMessage,
  ];
}
