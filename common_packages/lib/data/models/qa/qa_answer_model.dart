import 'package:common_packages/domain/entities/qa/qa_answer_entity.dart';

class QaAnswerModel extends QaAnswerEntity {
  const QaAnswerModel({
    required super.id,
    required super.userId,
    required super.friendshipId,
    required super.questionIndex,
    required super.questionDate,
    required super.answerText,
    super.createdAt,
  });

  factory QaAnswerModel.fromJson(Map<String, dynamic> json) {
    return QaAnswerModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      friendshipId: json['friendship_id'] as String,
      questionIndex: json['question_index'] as int,
      questionDate: DateTime.parse(json['question_date'] as String),
      answerText: json['answer_text'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
