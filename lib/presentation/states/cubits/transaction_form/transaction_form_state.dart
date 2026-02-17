import 'package:equatable/equatable.dart';
import 'package:tracker/domain/entities/transaction.dart';
import 'package:tracker/domain/usecases/transactions/transaction_categories.dart';

class TransactionFormState extends Equatable {
  const TransactionFormState({
    required this.id,
    required this.isEditing,
    required this.type,
    required this.category,
    required this.date,
    required this.categoryQuery,
  });

  final String id;
  final bool isEditing;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String categoryQuery;

  factory TransactionFormState.fromInitial({
    required Transaction? initial,
    required String generatedId,
  }) {
    final type = initial?.type ?? TransactionType.expense;
    final categories = TransactionCategories.forType(type);
    final initialCategory = initial?.category;
    final category =
        initialCategory != null && categories.contains(initialCategory)
        ? initialCategory
        : TransactionCategories.defaultFor(type);

    return TransactionFormState(
      id: initial?.id ?? generatedId,
      isEditing: initial != null,
      type: type,
      category: category,
      date: initial?.date ?? DateTime.now(),
      categoryQuery: '',
    );
  }

  List<String> get categories => TransactionCategories.forType(type);

  List<String> get filteredCategories {
    final query = categoryQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return categories;
    }
    return categories
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }

  TransactionFormState copyWith({
    TransactionType? type,
    String? category,
    DateTime? date,
    String? categoryQuery,
  }) {
    return TransactionFormState(
      id: id,
      isEditing: isEditing,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      categoryQuery: categoryQuery ?? this.categoryQuery,
    );
  }

  @override
  List<Object?> get props => [
    id,
    isEditing,
    type,
    category,
    date,
    categoryQuery,
  ];
}
