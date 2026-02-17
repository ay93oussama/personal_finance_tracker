import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tracker/core/services/id_service.dart';
import 'package:tracker/core/usecases/usecase.dart';
import 'package:tracker/domain/entities/transaction.dart';
import 'package:tracker/domain/entities/transaction_filter.dart';
import 'package:tracker/domain/repositories/transaction_repository.dart';
import 'package:tracker/domain/usecases/transactions/add_transaction_usecase.dart';
import 'package:tracker/domain/usecases/transactions/delete_transaction_usecase.dart';
import 'package:tracker/domain/usecases/transactions/get_transactions_usecase.dart';
import 'package:tracker/domain/usecases/transactions/update_transaction_usecase.dart';

import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit(TransactionRepository repository)
    : _getTransactions = GetTransactionsUseCase(repository),
      _addTransaction = AddTransactionUseCase(repository),
      _updateTransaction = UpdateTransactionUseCase(repository),
      _deleteTransaction = DeleteTransactionUseCase(repository),
      super(TransactionsState.initial());

  final GetTransactionsUseCase _getTransactions;
  final AddTransactionUseCase _addTransaction;
  final UpdateTransactionUseCase _updateTransaction;
  final DeleteTransactionUseCase _deleteTransaction;

  Future<void> load() async {
    emit(state.copyWith(status: TransactionsStatus.loading));
    final result = await _getTransactions(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (items) {
        emit(
          state.copyWith(
            status: TransactionsStatus.ready,
            transactions: items,
            errorMessage: null,
          ),
        );
      },
    );
  }

  Future<void> addTransaction(Transaction transaction) async {
    final result = await _addTransaction(AddTransactionParams(transaction));
    if (result.isLeft()) {
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: TransactionsStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (_) {},
      );
      return;
    }
    await load();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final result = await _updateTransaction(
      UpdateTransactionParams(transaction),
    );
    if (result.isLeft()) {
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: TransactionsStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (_) {},
      );
      return;
    }
    await load();
  }

  Future<void> deleteTransaction(String id) async {
    final updated = state.transactions.where((t) => t.id != id).toList();
    emit(
      state.copyWith(status: TransactionsStatus.ready, transactions: updated),
    );
    final result = await _deleteTransaction(DeleteTransactionParams(id));
    result.fold((failure) {
      emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }, (_) {});
  }

  Future<void> addDemoTransactions() async {
    for (final transaction in _demoTransactions()) {
      final result = await _addTransaction(AddTransactionParams(transaction));
      if (result.isLeft()) {
        result.fold((failure) {
          emit(
            state.copyWith(
              status: TransactionsStatus.failure,
              errorMessage: failure.message,
            ),
          );
        }, (_) {});
        return;
      }
    }
    await load();
  }

  void setFilter(TransactionFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void toggleFilter(TransactionFilter target) {
    final next = state.filter == target ? TransactionFilter.all : target;
    emit(state.copyWith(filter: next));
  }

  void setDateRange(DateTimeRange? range) {
    emit(state.copyWith(dateRange: range, clearDateRange: range == null));
  }

  List<Transaction> _demoTransactions() {
    final now = DateTime.now();

    return [
      Transaction(
        id: IdService.nextId(),
        type: TransactionType.income,
        amount: 3509,
        title: 'Salary',
        category: 'Salary',
        date: now,
      ),
      Transaction(
        id: IdService.nextId(),
        type: TransactionType.income,
        amount: 1833,
        title: 'Freelance',
        category: 'Freelance',
        date: now,
      ),
      Transaction(
        id: IdService.nextId(),
        type: TransactionType.expense,
        amount: 1360,
        title: 'Rent',
        category: 'Rent',
        date: now,
      ),
      Transaction(
        id: IdService.nextId(),
        type: TransactionType.expense,
        amount: 105,
        title: 'Electricity',
        category: 'Electricity',
        date: now,
      ),
      Transaction(
        id: IdService.nextId(),
        type: TransactionType.expense,
        amount: 500,
        title: 'Groceries',
        category: 'Groceries',
        date: now,
      ),
      Transaction(
        id: IdService.nextId(),
        type: TransactionType.expense,
        amount: 110,
        title: 'Mobile Phone',
        category: 'Mobile Phone',
        date: now,
      ),
      Transaction(
        id: IdService.nextId(),
        type: TransactionType.expense,
        amount: 19,
        title: 'Internet',
        category: 'Internet',
        date: now,
      ),
      Transaction(
        id: IdService.nextId(),
        type: TransactionType.expense,
        amount: 103,
        title: 'Car Insurance',
        category: 'Car Insurance',
        date: now,
      ),
      Transaction(
        id: IdService.nextId(),
        type: TransactionType.expense,
        amount: 4.99,
        title: 'Streaming Services',
        category: 'Streaming Services',
        date: now,
      ),
    ];
  }
}
