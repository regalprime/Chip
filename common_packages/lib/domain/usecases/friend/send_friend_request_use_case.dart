import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/friendship/friendship_entity.dart';
import 'package:common_packages/domain/repositories/friend_repository.dart';

class SendFriendRequestUseCase extends UseCase<FriendshipEntity, String> {
  final FriendRepository _repository;

  SendFriendRequestUseCase(this._repository);

  @override
  Future<Result<FriendshipEntity>> call(String addresseeId) {
    return _repository.sendFriendRequest(addresseeId: addresseeId);
  }
}
