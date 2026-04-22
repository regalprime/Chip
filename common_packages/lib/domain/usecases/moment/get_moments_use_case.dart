import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/moment/moment_entity.dart';
import 'package:common_packages/domain/repositories/moment_repository.dart';

class GetMomentsUseCase extends UseCaseNoParams<List<MomentEntity>> {
  final MomentRepository _repository;

  GetMomentsUseCase(this._repository);

  @override
  Future<Result<List<MomentEntity>>> call() {
    return _repository.getMoments();
  }
}
