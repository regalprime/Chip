import 'package:common_packages/core/error/exception.dart';
import 'package:common_packages/domain/entities/day_counter/day_counter_entity.dart';
import 'package:common_packages/domain/repositories/day_counter_repository.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';

class DayCounterRepositoryImpl implements DayCounterRepository {
  const DayCounterRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RemoteDataSource _remoteDataSource;

  @override
  Future<List<DayCounterEntity>> getDayCounters() async {
    try {
      return await _remoteDataSource.getDayCounters();
    } catch (e) {
      throw ServerException('Failed to get day counters: $e');
    }
  }

  @override
  Future<DayCounterEntity> addDayCounter({
    required String title,
    required DateTime targetDate,
    String emoji = '❤️',
    String colorHex = 'FFD32F2F',
    String? note,
  }) async {
    try {
      return await _remoteDataSource.addDayCounter(
        title: title,
        targetDate: targetDate,
        emoji: emoji,
        colorHex: colorHex,
        note: note,
      );
    } catch (e) {
      throw ServerException('Failed to add day counter: $e');
    }
  }

  @override
  Future<DayCounterEntity> updateDayCounter({
    required String id,
    required String title,
    required DateTime targetDate,
    String emoji = '❤️',
    String colorHex = 'FFD32F2F',
    String? note,
  }) async {
    try {
      return await _remoteDataSource.updateDayCounter(
        id: id,
        title: title,
        targetDate: targetDate,
        emoji: emoji,
        colorHex: colorHex,
        note: note,
      );
    } catch (e) {
      throw ServerException('Failed to update day counter: $e');
    }
  }

  @override
  Future<void> deleteDayCounter({required String id}) async {
    try {
      await _remoteDataSource.deleteDayCounter(id: id);
    } catch (e) {
      throw ServerException('Failed to delete day counter: $e');
    }
  }
}
