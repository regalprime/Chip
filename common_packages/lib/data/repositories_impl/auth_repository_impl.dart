import 'package:common_packages/core/error/exception.dart';
import 'package:common_packages/data/models/user/user_model.dart';
import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/domain/repositories/auth_repository.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required RemoteDataSource remoteDataSource}) : _remoteDataSource = remoteDataSource;

  final RemoteDataSource _remoteDataSource;

  @override
  Future<UserEntity?> getCurrentUserOnce() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUserOnce();
      return userModel;
    } catch (e) {
      throw ServerException('Failed to get current user: $e');
    }
  }

  @override
  Stream<UserEntity?> get currentUserStream {
    return _remoteDataSource.getCurrentUserStream().map((user) => user);
  }

  @override
  Future<UserEntity?> signInWithEmail({required String email, required String password}) async {
    try {
      return await _remoteDataSource.signInWithEmail(email: email, password: password);
    } catch (e) {
      throw ServerException('Failed to sign in with email: $e');
    }
  }

  @override
  Future<UserEntity?> signUpWithEmail({required String email, required String password}) async {
    try {
      return await _remoteDataSource.signUpWithEmail(email: email, password: password);
    } catch (e) {
      throw ServerException('Failed to sign up with email: $e');
    }
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      if (user != null) {
        await _remoteDataSource.saveUserToSupabase(user);
      }
      return user;
    } catch (e) {
      throw ServerException('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } catch (e) {
      throw ServerException('Failed to sign out: $e');
    }
  }

  @override
  Future<void> saveUserToSupabase(UserEntity user) async {
    try {
      if (user is! UserModel) {
        throw ServerException('Invalid user type: Expected UserModel');
      }
      await _remoteDataSource.saveUserToSupabase(user);
    } catch (e) {
      throw ServerException('Failed to save user to Supabase: $e');
    }
  }
}
