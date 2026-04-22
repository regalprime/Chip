import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/moment/moment_entity.dart';
import 'package:common_packages/domain/repositories/moment_repository.dart';

class SendMomentParams {
  final String? content;
  final String? imagePath;
  final String? mood;

  const SendMomentParams({this.content, this.imagePath, this.mood});
}

class SendMomentUseCase extends UseCase<MomentEntity, SendMomentParams> {
  final MomentRepository _repository;

  SendMomentUseCase(this._repository);

  @override
  Future<Result<MomentEntity>> call(SendMomentParams params) {
    return _repository.sendMoment(
      content: params.content,
      imagePath: params.imagePath,
      mood: params.mood,
    );
  }
}
