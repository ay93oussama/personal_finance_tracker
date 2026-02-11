import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/transaction_repository.dart';

class DeleteTransactionUseCase extends UseCase<Unit, DeleteTransactionParams> {
  const DeleteTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteTransactionParams params) {
    return _repository.delete(params.id);
  }
}

class DeleteTransactionParams extends Equatable {
  const DeleteTransactionParams(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}
