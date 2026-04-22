import 'package:common_packages/core/error/exception.dart';
import 'package:common_packages/domain/entities/qa/qa_answer_entity.dart';
import 'package:common_packages/domain/entities/qa/qa_daily_entity.dart';
import 'package:common_packages/domain/entities/qa/qa_question_pool.dart';
import 'package:common_packages/domain/repositories/qa_repository.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';

class QaRepositoryImpl implements QaRepository {
  const QaRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RemoteDataSource _remoteDataSource;

  /// Deterministic question index: both users in a pair get the same question per day.
  static int getQuestionIndex(String date, String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    final pairKey = sorted.join('_');
    final hash = (date + pairKey).hashCode.abs();
    return hash % kQuestionPool.length;
  }

  static String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Future<QaDailyEntity> getTodayQuestion({
    required String friendshipId,
    required String partnerUid,
  }) async {
    try {
      final myUid = await _remoteDataSource.getCurrentUid();
      final now = DateTime.now();
      final todayStr = _dateStr(now);
      final questionIndex = getQuestionIndex(todayStr, myUid, partnerUid);

      final answers = await _remoteDataSource.getQaAnswersForDate(
        friendshipId: friendshipId,
        date: now,
      );

      QaAnswerEntity? myAnswer;
      QaAnswerEntity? partnerAnswer;
      for (final a in answers) {
        if (a.userId == myUid) {
          myAnswer = a;
        } else {
          partnerAnswer = a;
        }
      }

      return QaDailyEntity(
        questionText: kQuestionPool[questionIndex],
        questionIndex: questionIndex,
        questionDate: now,
        friendshipId: friendshipId,
        myAnswer: myAnswer,
        partnerAnswer: partnerAnswer,
      );
    } catch (e) {
      throw ServerException('Failed to get today question: $e');
    }
  }

  @override
  Future<QaAnswerEntity> submitAnswer({
    required String friendshipId,
    required int questionIndex,
    required DateTime questionDate,
    required String answerText,
  }) async {
    try {
      return await _remoteDataSource.submitQaAnswer(
        friendshipId: friendshipId,
        questionIndex: questionIndex,
        questionDate: questionDate,
        answerText: answerText,
      );
    } catch (e) {
      throw ServerException('Failed to submit answer: $e');
    }
  }

  @override
  Future<List<QaDailyEntity>> getQaHistory({
    required String friendshipId,
    required String partnerUid,
  }) async {
    try {
      final myUid = await _remoteDataSource.getCurrentUid();
      final answers = await _remoteDataSource.getQaAnswerHistory(friendshipId: friendshipId);

      // Group by question_date
      final grouped = <String, List<QaAnswerEntity>>{};
      for (final a in answers) {
        final key = _dateStr(a.questionDate);
        grouped.putIfAbsent(key, () => []).add(a);
      }

      final result = <QaDailyEntity>[];
      for (final entry in grouped.entries) {
        final dateAnswers = entry.value;
        if (dateAnswers.isEmpty) continue;

        final qIndex = dateAnswers.first.questionIndex;
        final qDate = dateAnswers.first.questionDate;

        QaAnswerEntity? myAnswer;
        QaAnswerEntity? partnerAnswer;
        for (final a in dateAnswers) {
          if (a.userId == myUid) {
            myAnswer = a;
          } else {
            partnerAnswer = a;
          }
        }

        result.add(QaDailyEntity(
          questionText: qIndex < kQuestionPool.length
              ? kQuestionPool[qIndex]
              : 'Cau hoi #$qIndex',
          questionIndex: qIndex,
          questionDate: qDate,
          friendshipId: friendshipId,
          myAnswer: myAnswer,
          partnerAnswer: partnerAnswer,
        ));
      }

      return result;
    } catch (e) {
      throw ServerException('Failed to get Q&A history: $e');
    }
  }
}
