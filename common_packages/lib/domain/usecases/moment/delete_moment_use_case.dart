import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/repositories/moment_repository.dart';

class DeleteMomentUseCase extends UseCase<void, String> {
  final MomentRepository _repository;

  DeleteMomentUseCase(this._repository);

  @override
  Future<Result<void>> call(String momentId) {
    return _repository.deleteMoment(momentId: momentId);
  }
}
