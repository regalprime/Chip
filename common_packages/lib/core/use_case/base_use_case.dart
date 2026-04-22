import 'package:common_packages/core/result/result.dart';

abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

abstract class UseCaseNoParams<Type> {
  Future<Result<Type>> call();
}

class NoParams {
  const NoParams();
}
