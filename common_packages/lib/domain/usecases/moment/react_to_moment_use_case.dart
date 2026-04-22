import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/moment/moment_entity.dart';
import 'package:common_packages/domain/repositories/moment_repository.dart';

class ReactToMomentParams {
  final String momentId;
  final String emoji;

  const ReactToMomentParams({required this.momentId, required this.emoji});
}

class ReactToMomentUseCase extends UseCase<MomentReactionEntity, ReactToMomentParams> {
  final MomentRepository _repository;

  ReactToMomentUseCase(this._repository);

  @override
  Future<Result<MomentReactionEntity>> call(ReactToMomentParams params) {
    return _repository.reactToMoment(
      momentId: params.momentId,
      emoji: params.emoji,
    );
  }
}
