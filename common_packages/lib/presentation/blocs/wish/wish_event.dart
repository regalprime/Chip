part of 'wish_bloc.dart';

sealed class WishEvent extends Equatable {
  const WishEvent();

  @override
  List<Object?> get props => [];
}

class LoadWishesEvent extends WishEvent {
  const LoadWishesEvent();
}

class AddWishEvent extends WishEvent {
  const AddWishEvent({required this.title, this.description, this.emoji = '⭐'});

  final String title;
  final String? description;
  final String emoji;

  @override
  List<Object?> get props => [title, description, emoji];
}

class UpdateWishEvent extends WishEvent {
  const UpdateWishEvent({required this.id, required this.title, this.description, this.emoji = '⭐'});

  final String id;
  final String title;
  final String? description;
  final String emoji;

  @override
  List<Object?> get props => [id, title, description, emoji];
}

class CompleteWishEvent extends WishEvent {
  const CompleteWishEvent({required this.id, this.completionNote});

  final String id;
  final String? completionNote;

  @override
  List<Object?> get props => [id, completionNote];
}

class UncompleteWishEvent extends WishEvent {
  const UncompleteWishEvent({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

class DeleteWishEvent extends WishEvent {
  const DeleteWishEvent({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
