import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/domain/repositories/profile_repository.dart';

class UpdateProfileParams {
  final String displayName;
  final String? bio;
  final String? avatarFilePath;

  const UpdateProfileParams({required this.displayName, this.bio, this.avatarFilePath});
}

class UpdateProfileUseCase extends UseCase<UserEntity, UpdateProfileParams> {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  @override
  Future<Result<UserEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      displayName: params.displayName,
      bio: params.bio,
      avatarFilePath: params.avatarFilePath,
    );
  }
}
