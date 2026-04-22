import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/repositories/friend_repository.dart';

class RespondFriendRequestParams {
  final String friendshipId;
  final bool accept;

  const RespondFriendRequestParams({required this.friendshipId, required this.accept});
}

class RespondFriendRequestUseCase extends UseCase<void, RespondFriendRequestParams> {
  final FriendRepository _repository;

  RespondFriendRequestUseCase(this._repository);

  @override
  Future<Result<void>> call(RespondFriendRequestParams params) {
    return _repository.respondFriendRequest(
      friendshipId: params.friendshipId,
      accept: params.accept,
    );
  }
}
