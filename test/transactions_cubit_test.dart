import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/core/errors/failures.dart';
import 'package:tracker/domain/entities/transaction.dart';
import 'package:tracker/domain/entities/transaction_filter.dart';
import 'package:tracker/domain/repositories/transaction_repository.dart';
import 'package:tracker/presentation/states/cubits/transactions/transactions_cubit.dart';
import 'package:tracker/presentation/states/cubits/transactions/transactions_state.dart';

class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository(this._items);

  final List<Transaction> _items;

  @override
  Future<Either<Failure, Unit>> add(Transaction transaction) async {
    _items.removeWhere((item) => item.id == transaction.id);
    _items.add(transaction);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<Transaction>>> fetchAll() async {
    return Right(List<Transaction>.from(_items));
  }

  @override
  Future<Either<Failure, Unit>> update(Transaction transaction) async {
    _items.removeWhere((item) => item.id == transaction.id);
    _items.add(transaction);
    return const Right(unit);
  }
}

void main() {
  test('load sorts transactions and computes balance', () async {
    final repo = FakeTransactionRepository([
      Transaction(
        id: '1',
        type: TransactionType.expense,
        amount: 20,
        title: 'Lunch',
        category: 'Food',
        date: DateTime(2024, 1, 1),
      ),
      Transaction(
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
      Transaction(
        id: '1',
        type: TransactionType.expense,
        amount: 20,
        title: 'Snacks',
        category: 'Food',
        date: DateTime(2024, 1, 15),
      ),
      Transaction(
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
      DateTimeRange(start: DateTime(2024, 2, 1), end: DateTime(2024, 2, 2)),
    );

    expect(cubit.state.filteredTransactions.isEmpty, true);
  });

  test('toggleFilter applies and clears active filter', () async {
    final repo = FakeTransactionRepository([]);
    final cubit = TransactionsCubit(repo);

    cubit.toggleFilter(TransactionFilter.expense);
    expect(cubit.state.filter, TransactionFilter.expense);

    cubit.toggleFilter(TransactionFilter.expense);
    expect(cubit.state.filter, TransactionFilter.all);
  });

  test('add, update, delete refreshes state', () async {
    final repo = FakeTransactionRepository([]);
    final cubit = TransactionsCubit(repo);

    await cubit.addTransaction(
      Transaction(
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
      Transaction(
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
