import 'package:common_packages/domain/entities/qa/qa_answer_entity.dart';
import 'package:common_packages/domain/entities/qa/qa_daily_entity.dart';

abstract class QaRepository {
  Future<QaDailyEntity> getTodayQuestion({required String friendshipId, required String partnerUid});
  Future<QaAnswerEntity> submitAnswer({
    required String friendshipId,
    required int questionIndex,
    required DateTime questionDate,
    required String answerText,
  });
  Future<List<QaDailyEntity>> getQaHistory({required String friendshipId, required String partnerUid});
}
