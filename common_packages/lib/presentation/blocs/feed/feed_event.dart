part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedEvent extends FeedEvent {
  const LoadFeedEvent();
}

class ShareItemEvent extends FeedEvent {
  final String friendId;
  final String itemId;
  final String itemType;

  const ShareItemEvent({
    required this.friendId,
    required this.itemId,
    required this.itemType,
  });

  @override
  List<Object?> get props => [friendId, itemId, itemType];
}
