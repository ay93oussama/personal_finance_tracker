import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit(this._repository) : super(TransactionsState.initial());

  final TransactionRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: TransactionsStatus.loading));
    try {
      final items = await _repository.fetchAll();
      final balance = _calculateBalance(items);
      emit(
        state.copyWith(
          status: TransactionsStatus.ready,
          transactions: items,
          displayBalance: balance,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _repository.add(transaction);
    await load();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _repository.update(transaction);
    await load();
  }

  Future<void> deleteTransaction(String id) async {
    final updated = state.transactions.where((t) => t.id != id).toList();
    final balance = _calculateBalance(updated);
    emit(
      state.copyWith(
        status: TransactionsStatus.ready,
        transactions: updated,
        displayBalance: balance,
      ),
    );
    try {
      await _repository.delete(id);
    } catch (error) {
      emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> addDemoTransactions() async {
    for (final transaction in _demoTransactions()) {
      await _repository.add(transaction);
    }
    await load();
  }

  void setFilter(TransactionFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void setDateRange(DateTimeRange? range) {
    emit(state.copyWith(dateRange: range, clearDateRange: range == null));
  }

  double _calculateBalance(List<TransactionModel> items) {
    return items.fold<double>(
      0,
      (total, transaction) {
        final signed = transaction.type == TransactionType.income
            ? transaction.amount
            : -transaction.amount;
        return total + signed;
      },
    );
  }

  List<TransactionModel> _demoTransactions() {
    final now = DateTime.now();
    var seed = DateTime.now().microsecondsSinceEpoch;
    String id() => (seed++).toString();

    return [
      TransactionModel(
        id: id(),
        type: TransactionType.income,
        amount: 3509,
        title: 'Salary',
        category: 'Salary',
        date: now,
      ),
      TransactionModel(
        id: id(),
        type: TransactionType.income,
        amount: 1833,
        title: 'Freelance',
        category: 'Freelance',
        date: now,
      ),
      TransactionModel(
        id: id(),
        type: TransactionType.expense,
        amount: 1360,
        title: 'Rent',
        category: 'Rent',
        date: now,
      ),
      TransactionModel(
        id: id(),
        type: TransactionType.expense,
        amount: 105,
        title: 'Electricity',
        category: 'Electricity',
        date: now,
      ),
      TransactionModel(
        id: id(),
        type: TransactionType.expense,
        amount: 500,
        title: 'Groceries',
        category: 'Groceries',
        date: now,
      ),
      TransactionModel(
        id: id(),
        type: TransactionType.expense,
        amount: 110,
        title: 'Mobile Phone',
        category: 'Mobile Phone',
        date: now,
      ),
      TransactionModel(
        id: id(),
        type: TransactionType.expense,
        amount: 19,
        title: 'Internet',
        category: 'Internet',
        date: now,
      ),
      TransactionModel(
        id: id(),
        type: TransactionType.expense,
        amount: 103,
        title: 'Car Insurance',
        category: 'Car Insurance',
        date: now,
      ),
      TransactionModel(
        id: id(),
        type: TransactionType.expense,
        amount: 4.99,
        title: 'Streaming Services',
        category: 'Streaming Services',
        date: now,
      ),
    ];
  }
}
