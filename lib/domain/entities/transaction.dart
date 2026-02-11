import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.category,
    required this.date,
    this.note,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String title;
  final String category;
  final DateTime date;
  final String? note;

  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? title,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, type, amount, title, category, date, note];
}

enum TransactionType { income, expense }
