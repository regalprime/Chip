import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/repositories/friend_repository.dart';

class ShareItemParams {
  final String friendId;
  final String itemId;
  final String itemType;

  const ShareItemParams({required this.friendId, required this.itemId, required this.itemType});
}

class ShareItemUseCase extends UseCase<void, ShareItemParams> {
  final FriendRepository _repository;

  ShareItemUseCase(this._repository);

  @override
  Future<Result<void>> call(ShareItemParams params) {
    return _repository.shareItem(
      friendId: params.friendId,
      itemId: params.itemId,
      itemType: params.itemType,
    );
  }
}
