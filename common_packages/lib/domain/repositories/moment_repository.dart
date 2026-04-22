import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/moment/moment_entity.dart';

abstract class MomentRepository {
  Future<Result<MomentEntity>> sendMoment({
    String? content,
    String? imagePath,
    String? mood,
  });
  Future<Result<List<MomentEntity>>> getMoments();
  Future<Result<MomentReactionEntity>> reactToMoment({
    required String momentId,
    required String emoji,
  });
  Future<Result<void>> deleteMoment({required String momentId});
}
