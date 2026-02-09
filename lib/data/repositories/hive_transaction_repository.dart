import 'package:hive/hive.dart';

import '../models/transaction_model.dart';
import 'transaction_repository.dart';

class HiveTransactionRepository implements TransactionRepository {
  HiveTransactionRepository._(this._box);

  static const String boxName = 'transactions';

  final Box<TransactionModel> _box;

  static Future<HiveTransactionRepository> create() async {
    final box = await Hive.openBox<TransactionModel>(boxName);
    return HiveTransactionRepository._(box);
  }

  @override
  Future<List<TransactionModel>> fetchAll() async {
    final items = _box.values.toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Future<void> add(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  @override
  Future<void> update(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
