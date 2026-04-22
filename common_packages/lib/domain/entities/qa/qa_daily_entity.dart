import 'package:common_packages/domain/entities/qa/qa_answer_entity.dart';
import 'package:equatable/equatable.dart';

class QaDailyEntity extends Equatable {
  const QaDailyEntity({
    required this.questionText,
    required this.questionIndex,
    required this.questionDate,
    required this.friendshipId,
    this.myAnswer,
    this.partnerAnswer,
  });

  final String questionText;
  final int questionIndex;
  final DateTime questionDate;
  final String friendshipId;
  final QaAnswerEntity? myAnswer;
  final QaAnswerEntity? partnerAnswer;

  bool get bothAnswered => myAnswer != null && partnerAnswer != null;
  bool get iAnswered => myAnswer != null;

  @override
  List<Object?> get props => [questionText, questionIndex, questionDate, friendshipId, myAnswer, partnerAnswer];
}
