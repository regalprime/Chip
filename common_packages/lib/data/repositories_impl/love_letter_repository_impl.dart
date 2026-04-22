import 'package:common_packages/core/error/exception.dart';
import 'package:common_packages/domain/entities/love_letter/love_letter_entity.dart';
import 'package:common_packages/domain/repositories/love_letter_repository.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';

class LoveLetterRepositoryImpl implements LoveLetterRepository {
  const LoveLetterRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RemoteDataSource _remoteDataSource;

  @override
  Future<List<LoveLetterEntity>> getSentLetters() async {
    try {
      return await _remoteDataSource.getSentLetters();
    } catch (e) {
      throw ServerException('Failed to get sent letters: $e');
    }
  }

  @override
  Future<List<LoveLetterEntity>> getReceivedLetters() async {
    try {
      return await _remoteDataSource.getReceivedLetters();
    } catch (e) {
      throw ServerException('Failed to get received letters: $e');
    }
  }

  @override
  Future<LoveLetterEntity> sendLetter({
    required String recipientId,
    required String title,
    required String content,
    required DateTime deliveryDate,
  }) async {
    try {
      return await _remoteDataSource.sendLoveLetter(
        recipientId: recipientId,
        title: title,
        content: content,
        deliveryDate: deliveryDate,
      );
    } catch (e) {
      throw ServerException('Failed to send letter: $e');
    }
  }

  @override
  Future<LoveLetterEntity> markAsRead({required String id}) async {
    try {
      return await _remoteDataSource.markLetterAsRead(id: id);
    } catch (e) {
      throw ServerException('Failed to mark letter as read: $e');
    }
  }

  @override
  Future<void> deleteLetter({required String id}) async {
    try {
      await _remoteDataSource.deleteLoveLetter(id: id);
    } catch (e) {
      throw ServerException('Failed to delete letter: $e');
    }
  }
}
