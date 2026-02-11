import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> fetchAll();
  Future<Either<Failure, Unit>> add(Transaction transaction);
  Future<Either<Failure, Unit>> update(Transaction transaction);
  Future<Either<Failure, Unit>> delete(String id);
}
