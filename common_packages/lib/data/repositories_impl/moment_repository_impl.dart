import 'package:common_packages/core/error/app_failure.dart';
import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/moment/moment_entity.dart';
import 'package:common_packages/domain/repositories/moment_repository.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';

class MomentRepositoryImpl implements MomentRepository {
  const MomentRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RemoteDataSource _remoteDataSource;

  @override
  Future<Result<MomentEntity>> sendMoment({
    String? content,
    String? imagePath,
    String? mood,
  }) async {
    try {
      final moment = await _remoteDataSource.sendMoment(
        content: content,
        imagePath: imagePath,
        mood: mood,
      );
      return Success(moment);
    } catch (e) {
      return Failure(ServerFailure('Failed to send moment: $e'));
    }
  }

  @override
  Future<Result<List<MomentEntity>>> getMoments() async {
    try {
      final moments = await _remoteDataSource.getMoments();
      return Success(moments);
    } catch (e) {
      return Failure(ServerFailure('Failed to get moments: $e'));
    }
  }

  @override
  Future<Result<MomentReactionEntity>> reactToMoment({
    required String momentId,
    required String emoji,
  }) async {
    try {
      final reaction = await _remoteDataSource.reactToMoment(
        momentId: momentId,
        emoji: emoji,
      );
      return Success(reaction);
    } catch (e) {
      return Failure(ServerFailure('Failed to react: $e'));
    }
  }

  @override
  Future<Result<void>> deleteMoment({required String momentId}) async {
    try {
      await _remoteDataSource.deleteMoment(momentId: momentId);
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to delete moment: $e'));
    }
  }
}
