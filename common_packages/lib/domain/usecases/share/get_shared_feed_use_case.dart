import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/share/shared_item_entity.dart';
import 'package:common_packages/domain/repositories/friend_repository.dart';

class GetSharedFeedUseCase extends UseCaseNoParams<List<SharedItemEntity>> {
  final FriendRepository _repository;

  GetSharedFeedUseCase(this._repository);

  @override
  Future<Result<List<SharedItemEntity>>> call() {
    return _repository.getSharedFeed();
  }
}
