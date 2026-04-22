part of 'qa_bloc.dart';

sealed class QaEvent extends Equatable {
  const QaEvent();

  @override
  List<Object?> get props => [];
}

class SelectFriendForQaEvent extends QaEvent {
  const SelectFriendForQaEvent({
    required this.friendshipId,
    required this.partnerUid,
    this.partnerName,
  });

  final String friendshipId;
  final String partnerUid;
  final String? partnerName;

  @override
  List<Object?> get props => [friendshipId, partnerUid, partnerName];
}

class LoadTodayQuestionEvent extends QaEvent {
  const LoadTodayQuestionEvent({required this.friendshipId, required this.partnerUid});

  final String friendshipId;
  final String partnerUid;

  @override
  List<Object?> get props => [friendshipId, partnerUid];
}

class SubmitQaAnswerEvent extends QaEvent {
  const SubmitQaAnswerEvent({
    required this.friendshipId,
    required this.questionIndex,
    required this.questionDate,
    required this.answerText,
  });

  final String friendshipId;
  final int questionIndex;
  final DateTime questionDate;
  final String answerText;

  @override
  List<Object?> get props => [friendshipId, questionIndex, questionDate, answerText];
}

class LoadQaHistoryEvent extends QaEvent {
  const LoadQaHistoryEvent({required this.friendshipId, required this.partnerUid});

  final String friendshipId;
  final String partnerUid;

  @override
  List<Object?> get props => [friendshipId, partnerUid];
}
