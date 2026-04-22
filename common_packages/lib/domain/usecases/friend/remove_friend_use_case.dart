import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/repositories/friend_repository.dart';

class RemoveFriendUseCase extends UseCase<void, String> {
  final FriendRepository _repository;

  RemoveFriendUseCase(this._repository);

  @override
  Future<Result<void>> call(String friendshipId) {
    return _repository.removeFriend(friendshipId: friendshipId);
  }
}
