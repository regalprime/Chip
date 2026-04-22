part of 'friend_bloc.dart';

sealed class FriendEvent extends Equatable {
  const FriendEvent();

  @override
  List<Object?> get props => [];
}

class LoadFriendsEvent extends FriendEvent {
  const LoadFriendsEvent();
}

class LoadFriendRequestsEvent extends FriendEvent {
  const LoadFriendRequestsEvent();
}

class SearchUsersEvent extends FriendEvent {
  final String query;

  const SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SendFriendRequestEvent extends FriendEvent {
  final String addresseeId;

  const SendFriendRequestEvent(this.addresseeId);

  @override
  List<Object?> get props => [addresseeId];
}

class RespondFriendRequestEvent extends FriendEvent {
  final String friendshipId;
  final bool accept;

  const RespondFriendRequestEvent({required this.friendshipId, required this.accept});

  @override
  List<Object?> get props => [friendshipId, accept];
}

class RemoveFriendEvent extends FriendEvent {
  final String friendshipId;

  const RemoveFriendEvent(this.friendshipId);

  @override
  List<Object?> get props => [friendshipId];
}
