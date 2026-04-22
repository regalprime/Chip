part of 'love_letter_bloc.dart';

sealed class LoveLetterEvent extends Equatable {
  const LoveLetterEvent();

  @override
  List<Object?> get props => [];
}

class LoadSentLettersEvent extends LoveLetterEvent {
  const LoadSentLettersEvent();
}

class LoadReceivedLettersEvent extends LoveLetterEvent {
  const LoadReceivedLettersEvent();
}

class SendLetterEvent extends LoveLetterEvent {
  const SendLetterEvent({
    required this.recipientId,
    required this.title,
    required this.content,
    required this.deliveryDate,
  });

  final String recipientId;
  final String title;
  final String content;
  final DateTime deliveryDate;

  @override
  List<Object?> get props => [recipientId, title, content, deliveryDate];
}

class MarkLetterReadEvent extends LoveLetterEvent {
  const MarkLetterReadEvent({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

class DeleteLetterEvent extends LoveLetterEvent {
  const DeleteLetterEvent({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
