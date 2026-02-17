import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/domain/entities/transaction.dart';
import 'package:tracker/presentation/states/cubits/transaction_form/transaction_form_cubit.dart';

void main() {
  test('initializes from existing transaction', () {
    final cubit = TransactionFormCubit(
      idGenerator: () => 'generated-id',
      initial: Transaction(
        id: 'existing-id',
        type: TransactionType.income,
        amount: 100,
        title: 'Salary',
        category: 'Salary',
        date: DateTime(2024, 1, 15),
      ),
    );

    expect(cubit.state.isEditing, true);
    expect(cubit.state.id, 'existing-id');
    expect(cubit.state.type, TransactionType.income);
    expect(cubit.state.category, 'Salary');
    expect(cubit.state.date, DateTime(2024, 1, 15));
  });

  test('setType keeps category if valid otherwise falls back to default', () {
    final cubit = TransactionFormCubit(idGenerator: () => 'id-1');

    cubit.setCategory('Salary');
    cubit.setType(TransactionType.income);
    expect(cubit.state.category, 'Salary');

    cubit.setType(TransactionType.expense);
    expect(cubit.state.category, 'Other');
  });

  test('buildTransaction parses amount and trims optional note', () {
    final cubit = TransactionFormCubit(idGenerator: () => 'new-id');
    cubit.setType(TransactionType.expense);
    cubit.setCategory('Rent');
    cubit.setDate(DateTime(2024, 2, 1));

    final transaction = cubit.buildTransaction(
      amountInput: '1200,50',
      noteInput: '  monthly  ',
    );

    expect(transaction, isNotNull);
    expect(transaction!.id, 'new-id');
    expect(transaction.amount, 1200.50);
    expect(transaction.note, 'monthly');
    expect(transaction.category, 'Rent');
  });

  test('buildTransaction returns null for invalid amount input', () {
    final cubit = TransactionFormCubit(idGenerator: () => 'new-id');

    final transaction = cubit.buildTransaction(
      amountInput: 'invalid',
      noteInput: '',
    );

    expect(transaction, isNull);
  });

  test('category query filters available categories', () {
    final cubit = TransactionFormCubit(idGenerator: () => 'id-1');
    cubit.setCategoryQuery('rent');

    expect(cubit.state.filteredCategories, contains('Rent'));
    expect(cubit.state.filteredCategories, isNot(contains('Salary')));
  });
}
