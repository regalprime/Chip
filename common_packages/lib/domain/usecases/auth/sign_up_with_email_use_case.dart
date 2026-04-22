import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/domain/repositories/auth_repository.dart';

class SignUpWithEmailUseCase {
  final AuthRepository _authRepository;

  const SignUpWithEmailUseCase(this._authRepository);

  Future<UserEntity?> call({
    required String email,
    required String password,
  }) async {
    return await _authRepository.signUpWithEmail(
      email: email,
      password: password,
    );
  }
}
