import 'package:common_packages/core/error/app_failure.dart';
import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/friendship/friendship_entity.dart';
import 'package:common_packages/domain/entities/share/shared_item_entity.dart';
import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/domain/repositories/friend_repository.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';

class FriendRepositoryImpl implements FriendRepository {
  const FriendRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<UserEntity>>> searchUsers({required String query}) async {
    try {
      final users = await _remoteDataSource.searchUsers(query: query);
      return Success(users);
    } catch (e) {
      return Failure(ServerFailure('Failed to search users: $e'));
    }
  }

  @override
  Future<Result<FriendshipEntity>> sendFriendRequest({required String addresseeId}) async {
    try {
      final friendship = await _remoteDataSource.sendFriendRequest(addresseeId: addresseeId);
      return Success(friendship);
    } catch (e) {
      return Failure(ServerFailure('Failed to send friend request: $e'));
    }
  }

  @override
  Future<Result<void>> respondFriendRequest({required String friendshipId, required bool accept}) async {
    try {
      await _remoteDataSource.respondFriendRequest(friendshipId: friendshipId, accept: accept);
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to respond to friend request: $e'));
    }
  }

  @override
  Future<Result<List<FriendshipEntity>>> getFriendRequests() async {
    try {
      final requests = await _remoteDataSource.getFriendRequests();
      return Success(requests);
    } catch (e) {
      return Failure(ServerFailure('Failed to get friend requests: $e'));
    }
  }

  @override
  Future<Result<List<FriendshipEntity>>> getFriends() async {
    try {
      final friends = await _remoteDataSource.getFriends();
      return Success(friends);
    } catch (e) {
      return Failure(ServerFailure('Failed to get friends: $e'));
    }
  }

  @override
  Future<Result<void>> removeFriend({required String friendshipId}) async {
    try {
      await _remoteDataSource.removeFriend(friendshipId: friendshipId);
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to remove friend: $e'));
    }
  }

  @override
  Future<Result<void>> shareItem({
    required String friendId,
    required String itemId,
    required String itemType,
  }) async {
    try {
      await _remoteDataSource.shareItem(friendId: friendId, itemId: itemId, itemType: itemType);
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to share item: $e'));
    }
  }

  @override
  Future<Result<List<SharedItemEntity>>> getSharedFeed() async {
    try {
      final feed = await _remoteDataSource.getSharedFeed();
      return Success(feed);
    } catch (e) {
      return Failure(ServerFailure('Failed to get shared feed: $e'));
    }
  }
}
