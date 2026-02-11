import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected error']);
}
