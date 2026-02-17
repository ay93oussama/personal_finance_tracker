import '../../entities/transaction.dart';

class TransactionGroup {
  const TransactionGroup({required this.date, required this.transactions});

  final DateTime date;
  final List<Transaction> transactions;
}

class CategoryTotal {
  const CategoryTotal({required this.category, required this.total});

  final String category;
  final double total;
}

class TransactionAggregations {
  TransactionAggregations._();

  static double netBalance(List<Transaction> transactions) {
    return transactions.fold<double>(0, (total, transaction) {
      final signedAmount = transaction.type == TransactionType.income
          ? transaction.amount
          : -transaction.amount;
      return total + signedAmount;
    });
  }

  static List<TransactionGroup> groupByDate(List<Transaction> transactions) {
    final groups = <DateTime, List<Transaction>>{};
    for (final transaction in transactions) {
      // Normalize to date-only to avoid time-of-day affecting grouping.
      final key = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      groups.putIfAbsent(key, () => []).add(transaction);
    }

    for (final entries in groups.values) {
      entries.sort((a, b) => b.date.compareTo(a.date));
    }

    final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final key in keys)
        TransactionGroup(date: key, transactions: groups[key]!),
    ];
  }

  static List<CategoryTotal> totalsByCategory(
    List<Transaction> transactions, {
    TransactionType? type,
  }) {
    final totals = <String, double>{};
    for (final transaction in transactions) {
      if (type != null && transaction.type != type) {
        continue;
      }
      totals.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final list = [
      for (final entry in totals.entries)
        CategoryTotal(category: entry.key, total: entry.value),
    ];
    list.sort((a, b) => b.total.compareTo(a.total));
    return list;
  }
}
