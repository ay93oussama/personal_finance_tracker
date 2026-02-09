import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tracker/bloc/transactions/transactions_cubit.dart';
import 'package:tracker/bloc/transactions/transactions_state.dart';
import 'package:tracker/data/models/transaction_model.dart';
import 'package:tracker/data/repositories/transaction_repository.dart';

class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository(this._items);

  final List<TransactionModel> _items;

  @override
  Future<void> add(TransactionModel transaction) async {
    _items.removeWhere((item) => item.id == transaction.id);
    _items.add(transaction);
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<TransactionModel>> fetchAll() async {
    return List<TransactionModel>.from(_items);
  }

  @override
  Future<void> update(TransactionModel transaction) async {
    _items.removeWhere((item) => item.id == transaction.id);
    _items.add(transaction);
  }
}

void main() {
  test('load sorts transactions and computes balance', () async {
    final repo = FakeTransactionRepository([
      TransactionModel(
        id: '1',
        type: TransactionType.expense,
        amount: 20,
        title: 'Lunch',
        category: 'Food',
        date: DateTime(2024, 1, 1),
      ),
      TransactionModel(
        id: '2',
        type: TransactionType.income,
        amount: 100,
        title: 'Paycheck',
        category: 'Salary',
        date: DateTime(2024, 2, 1),
      ),
    ]);

    final cubit = TransactionsCubit(repo);
    await cubit.load();

    expect(cubit.state.status, TransactionsStatus.ready);
    expect(cubit.state.transactions.first.id, '1');
    expect(cubit.state.balance, 80);
  });

  test('filters by type and date range', () async {
    final repo = FakeTransactionRepository([
      TransactionModel(
        id: '1',
        type: TransactionType.expense,
        amount: 20,
        title: 'Snacks',
        category: 'Food',
        date: DateTime(2024, 1, 15),
      ),
      TransactionModel(
        id: '2',
        type: TransactionType.income,
        amount: 100,
        title: 'Salary',
        category: 'Salary',
        date: DateTime(2024, 2, 1),
      ),
    ]);

    final cubit = TransactionsCubit(repo);
    await cubit.load();
    cubit.setFilter(TransactionFilter.expense);

    expect(cubit.state.filteredTransactions.length, 1);

    cubit.setDateRange(
      DateTimeRange(
        start: DateTime(2024, 2, 1),
        end: DateTime(2024, 2, 2),
      ),
    );

    expect(cubit.state.filteredTransactions.isEmpty, true);
  });

  test('add, update, delete refreshes state', () async {
    final repo = FakeTransactionRepository([]);
    final cubit = TransactionsCubit(repo);

    await cubit.addTransaction(
      TransactionModel(
        id: '1',
        type: TransactionType.expense,
        amount: 10,
        title: 'Bills',
        category: 'Bills',
        date: DateTime(2024, 1, 1),
      ),
    );
    expect(cubit.state.transactions.length, 1);

    await cubit.updateTransaction(
      TransactionModel(
        id: '1',
        type: TransactionType.expense,
        amount: 15,
        title: 'Bills',
        category: 'Bills',
        date: DateTime(2024, 1, 1),
      ),
    );
    expect(cubit.state.transactions.first.amount, 15);

    await cubit.deleteTransaction('1');
    expect(cubit.state.transactions.isEmpty, true);
  });
}
