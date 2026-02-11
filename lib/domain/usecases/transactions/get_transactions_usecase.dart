import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

class GetTransactionsUseCase extends UseCase<List<Transaction>, NoParams> {
  const GetTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, List<Transaction>>> call(NoParams params) {
    return _repository.fetchAll();
  }
}
