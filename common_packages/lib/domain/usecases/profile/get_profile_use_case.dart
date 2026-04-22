import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/domain/repositories/profile_repository.dart';

class GetProfileUseCase extends UseCaseNoParams<UserEntity> {
  final ProfileRepository _repository;

  GetProfileUseCase(this._repository);

  @override
  Future<Result<UserEntity>> call() {
    return _repository.getProfile();
  }
}
