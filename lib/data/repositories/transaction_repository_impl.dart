import 'package:dartz/dartz.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../data_sources/local/transaction_local_data_source.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._localDataSource);

  final TransactionLocalDataSource _localDataSource;

  static Future<TransactionRepositoryImpl> create() async {
    final localDataSource = await HiveTransactionLocalDataSource.create();
    return TransactionRepositoryImpl(localDataSource);
  }

  @override
  Future<Either<Failure, List<Transaction>>> fetchAll() async {
    try {
      final models = await _localDataSource.fetchAll();
      final entities = models.map((item) => item.toEntity()).toList();
      return Right(entities);
    } on AppException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> add(Transaction transaction) async {
    try {
      await _localDataSource.add(TransactionModel.fromEntity(transaction));
      return const Right(unit);
    } on AppException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> update(Transaction transaction) async {
    try {
      await _localDataSource.update(TransactionModel.fromEntity(transaction));
      return const Right(unit);
    } on AppException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _localDataSource.delete(id);
      return const Right(unit);
    } on AppException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
