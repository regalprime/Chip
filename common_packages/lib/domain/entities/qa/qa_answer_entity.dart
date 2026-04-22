import 'package:equatable/equatable.dart';

class QaAnswerEntity extends Equatable {
  const QaAnswerEntity({
    required this.id,
    required this.userId,
    required this.friendshipId,
    required this.questionIndex,
    required this.questionDate,
    required this.answerText,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String friendshipId;
  final int questionIndex;
  final DateTime questionDate;
  final String answerText;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, userId, friendshipId, questionIndex, questionDate, answerText, createdAt];
}
