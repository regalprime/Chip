import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/friendship/friendship_entity.dart';
import 'package:common_packages/domain/entities/share/shared_item_entity.dart';
import 'package:common_packages/domain/entities/user/user_entity.dart';

abstract class FriendRepository {
  Future<Result<List<UserEntity>>> searchUsers({required String query});
  Future<Result<FriendshipEntity>> sendFriendRequest({required String addresseeId});
  Future<Result<void>> respondFriendRequest({required String friendshipId, required bool accept});
  Future<Result<List<FriendshipEntity>>> getFriendRequests();
  Future<Result<List<FriendshipEntity>>> getFriends();
  Future<Result<void>> removeFriend({required String friendshipId});
  Future<Result<void>> shareItem({
    required String friendId,
    required String itemId,
    required String itemType,
  });
  Future<Result<List<SharedItemEntity>>> getSharedFeed();
}
