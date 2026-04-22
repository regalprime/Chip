
import 'package:common_packages/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call() async {
    return await _authRepository.signOut();
  }
}
