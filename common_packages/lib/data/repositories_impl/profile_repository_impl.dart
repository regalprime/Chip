import 'package:common_packages/core/error/app_failure.dart';
import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/domain/repositories/profile_repository.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RemoteDataSource _remoteDataSource;

  @override
  Future<Result<UserEntity>> getProfile() async {
    try {
      final user = await _remoteDataSource.getProfile();
      return Success(user);
    } catch (e) {
      return Failure(ServerFailure('Failed to get profile: $e'));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile({
    required String displayName,
    String? bio,
    String? avatarFilePath,
  }) async {
    try {
      final user = await _remoteDataSource.updateProfile(
        displayName: displayName,
        bio: bio,
        avatarFilePath: avatarFilePath,
      );
      return Success(user);
    } catch (e) {
      return Failure(ServerFailure('Failed to update profile: $e'));
    }
  }
}
