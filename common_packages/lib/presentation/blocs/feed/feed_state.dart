part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, loaded, sharing, shared, error }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<SharedItemEntity> items;
  final String? errorMessage;

  const FeedState({
    this.status = FeedStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<SharedItemEntity>? items,
    String? errorMessage,
  }) {
    return FeedState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
