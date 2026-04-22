
import 'package:common_packages/domain/entities/user/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithGoogle();

  Future<UserEntity?> signInWithEmail({required String email, required String password});

  Future<UserEntity?> signUpWithEmail({required String email, required String password});

  Future<void> saveUserToSupabase(UserEntity user);

  Future<void> signOut();

  Future<UserEntity?> getCurrentUserOnce();

  Stream<UserEntity?> get currentUserStream;
}