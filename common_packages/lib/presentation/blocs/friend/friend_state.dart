part of 'friend_bloc.dart';

enum FriendStatus { initial, loading, searching, loaded, requestSent, error }

class FriendState extends Equatable {
  final FriendStatus status;
  final List<FriendshipEntity> friends;
  final List<FriendshipEntity> friendRequests;
  final List<UserEntity> searchResults;
  final String? errorMessage;

  const FriendState({
    this.status = FriendStatus.initial,
    this.friends = const [],
    this.friendRequests = const [],
    this.searchResults = const [],
    this.errorMessage,
  });

  FriendState copyWith({
    FriendStatus? status,
    List<FriendshipEntity>? friends,
    List<FriendshipEntity>? friendRequests,
    List<UserEntity>? searchResults,
    String? errorMessage,
  }) {
    return FriendState(
      status: status ?? this.status,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, friends, friendRequests, searchResults, errorMessage];
}
