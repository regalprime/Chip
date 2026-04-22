import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/friendship/friendship_entity.dart';
import 'package:common_packages/domain/repositories/friend_repository.dart';

class GetFriendRequestsUseCase extends UseCaseNoParams<List<FriendshipEntity>> {
  final FriendRepository _repository;

  GetFriendRequestsUseCase(this._repository);

  @override
  Future<Result<List<FriendshipEntity>>> call() {
    return _repository.getFriendRequests();
  }
}
