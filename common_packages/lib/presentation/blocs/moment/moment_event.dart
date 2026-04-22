part of 'moment_bloc.dart';

sealed class MomentEvent extends Equatable {
  const MomentEvent();

  @override
  List<Object?> get props => [];
}

class LoadMomentsEvent extends MomentEvent {
  const LoadMomentsEvent();
}

class SendMomentEvent extends MomentEvent {
  final String? content;
  final String? imagePath;
  final String? mood;

  const SendMomentEvent({this.content, this.imagePath, this.mood});

  @override
  List<Object?> get props => [content, imagePath, mood];
}

class ReactToMomentEvent extends MomentEvent {
  final String momentId;
  final String emoji;

  const ReactToMomentEvent({required this.momentId, required this.emoji});

  @override
  List<Object?> get props => [momentId, emoji];
}

class DeleteMomentEvent extends MomentEvent {
  final String momentId;

  const DeleteMomentEvent({required this.momentId});

  @override
  List<Object?> get props => [momentId];
}
