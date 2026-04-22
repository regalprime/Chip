import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/user/user_entity.dart';

abstract class ProfileRepository {
  Future<Result<UserEntity>> updateProfile({
    required String displayName,
    String? bio,
    String? avatarFilePath,
  });
  Future<Result<UserEntity>> getProfile();
}
