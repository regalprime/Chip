import 'package:common_packages/domain/entities/love_letter/love_letter_entity.dart';

abstract class LoveLetterRepository {
  Future<List<LoveLetterEntity>> getSentLetters();
  Future<List<LoveLetterEntity>> getReceivedLetters();
  Future<LoveLetterEntity> sendLetter({
    required String recipientId,
    required String title,
    required String content,
    required DateTime deliveryDate,
  });
  Future<LoveLetterEntity> markAsRead({required String id});
  Future<void> deleteLetter({required String id});
}
