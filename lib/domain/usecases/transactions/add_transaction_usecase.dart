import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

class AddTransactionUseCase extends UseCase<Unit, AddTransactionParams> {
  const AddTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(AddTransactionParams params) {
    return _repository.add(params.transaction);
  }
}

class AddTransactionParams extends Equatable {
  const AddTransactionParams(this.transaction);

  final Transaction transaction;

  @override
  List<Object> get props => [transaction];
}
