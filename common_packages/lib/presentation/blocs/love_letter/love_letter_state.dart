part of 'love_letter_bloc.dart';

enum LoveLetterStatus { initial, loading, saving, loaded, error }

class LoveLetterState extends Equatable {
  const LoveLetterState({
    this.status = LoveLetterStatus.initial,
    this.sentLetters = const [],
    this.receivedLetters = const [],
    this.errorMessage,
  });

  final LoveLetterStatus status;
  final List<LoveLetterEntity> sentLetters;
  final List<LoveLetterEntity> receivedLetters;
  final String? errorMessage;

  LoveLetterState copyWith({
    LoveLetterStatus? status,
    List<LoveLetterEntity>? sentLetters,
    List<LoveLetterEntity>? receivedLetters,
    String? errorMessage,
  }) {
    return LoveLetterState(
      status: status ?? this.status,
      sentLetters: sentLetters ?? this.sentLetters,
      receivedLetters: receivedLetters ?? this.receivedLetters,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, sentLetters, receivedLetters, errorMessage];
}
