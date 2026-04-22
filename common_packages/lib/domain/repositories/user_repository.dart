import 'package:common_packages/domain/entities/user/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUserProfile(String uid);
  Future<UserEntity> updateUserProfile(UserEntity user);

}