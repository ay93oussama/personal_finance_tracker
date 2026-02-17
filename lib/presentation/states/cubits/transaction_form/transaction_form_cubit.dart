import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker/domain/entities/transaction.dart';
import 'package:tracker/domain/usecases/transactions/transaction_categories.dart';
import 'package:tracker/presentation/states/cubits/transaction_form/transaction_form_state.dart';

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit({
    required String Function() idGenerator,
    Transaction? initial,
  }) : super(
         TransactionFormState.fromInitial(
           initial: initial,
           generatedId: initial?.id ?? idGenerator(),
         ),
       );

  void setType(TransactionType nextType) {
    final nextCategories = TransactionCategories.forType(nextType);
    final nextCategory = nextCategories.contains(state.category)
        ? state.category
        : TransactionCategories.defaultFor(nextType);

    emit(state.copyWith(type: nextType, category: nextCategory));
  }

  void setCategory(String category) {
    emit(state.copyWith(category: category));
  }

  void setDate(DateTime date) {
    emit(state.copyWith(date: date));
  }

  void setCategoryQuery(String query) {
    emit(state.copyWith(categoryQuery: query.trim()));
  }

  void clearCategoryQuery() {
    if (state.categoryQuery.isEmpty) {
      return;
    }
    emit(state.copyWith(categoryQuery: ''));
  }

  double? parseAmount(String input) {
    return double.tryParse(input.trim().replaceAll(',', '.'));
  }

  Transaction? buildTransaction({
    required String amountInput,
    required String noteInput,
  }) {
    final amount = parseAmount(amountInput);
    if (amount == null || amount <= 0) {
      return null;
    }

    final note = noteInput.trim();
    return Transaction(
      id: state.id,
      type: state.type,
      amount: amount,
      title: state.category,
      category: state.category,
      date: state.date,
      note: note.isEmpty ? null : note,
    );
  }
}
