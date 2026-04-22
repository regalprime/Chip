import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/domain/repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository _authRepository;

  const SignInWithEmailUseCase(this._authRepository);

  Future<UserEntity?> call({
    required String email,
    required String password,
  }) async {
    return await _authRepository.signInWithEmail(
      email: email,
      password: password,
    );
  }
}
