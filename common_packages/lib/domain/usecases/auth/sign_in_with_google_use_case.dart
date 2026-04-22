

import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository _authRepository;

  const SignInWithGoogleUseCase(this._authRepository);

  Future<UserEntity?> call() async {
    return await _authRepository.signInWithGoogle();
  }
}