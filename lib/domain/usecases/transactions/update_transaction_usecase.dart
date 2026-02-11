import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

class UpdateTransactionUseCase extends UseCase<Unit, UpdateTransactionParams> {
  const UpdateTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(UpdateTransactionParams params) {
    return _repository.update(params.transaction);
  }
}

class UpdateTransactionParams extends Equatable {
  const UpdateTransactionParams(this.transaction);

  final Transaction transaction;

  @override
  List<Object> get props => [transaction];
}
