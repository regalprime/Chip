part of 'wish_bloc.dart';

enum WishStatus { initial, loading, loaded, error }

class WishState extends Equatable {
  const WishState({
    this.status = WishStatus.initial,
    this.wishes = const [],
    this.errorMessage,
  });

  final WishStatus status;
  final List<WishEntity> wishes;
  final String? errorMessage;

  List<WishEntity> get pendingWishes => wishes.where((w) => !w.isCompleted).toList();
  List<WishEntity> get completedWishes => wishes.where((w) => w.isCompleted).toList();

  WishState copyWith({
    WishStatus? status,
    List<WishEntity>? wishes,
    String? errorMessage,
  }) {
    return WishState(
      status: status ?? this.status,
      wishes: wishes ?? this.wishes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, wishes, errorMessage];
}
