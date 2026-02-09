import '../models/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> fetchAll();
  Future<void> add(TransactionModel transaction);
  Future<void> update(TransactionModel transaction);
  Future<void> delete(String id);
}
