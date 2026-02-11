import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> fetchAll();
  Future<void> add(TransactionModel transaction);
  Future<void> update(TransactionModel transaction);
  Future<void> delete(String id);
}

class HiveTransactionLocalDataSource implements TransactionLocalDataSource {
  HiveTransactionLocalDataSource(this._box);

  final Box<TransactionModel> _box;

  static Future<HiveTransactionLocalDataSource> create() async {
    final box = await Hive.openBox<TransactionModel>(
      AppConstants.transactionsBoxName,
    );
    return HiveTransactionLocalDataSource(box);
  }

  @override
  Future<List<TransactionModel>> fetchAll() async {
    try {
      final items = _box.values.toList();
      items.sort((a, b) => b.date.compareTo(a.date));
      return items;
    } catch (_) {
      throw AppException('Failed to read local transactions');
    }
  }

  @override
  Future<void> add(TransactionModel transaction) async {
    try {
      await _box.put(transaction.id, transaction);
    } catch (_) {
      throw AppException('Failed to save transaction');
    }
  }

  @override
  Future<void> update(TransactionModel transaction) async {
    try {
      await _box.put(transaction.id, transaction);
    } catch (_) {
      throw AppException('Failed to update transaction');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (_) {
      throw AppException('Failed to delete transaction');
    }
  }
}
