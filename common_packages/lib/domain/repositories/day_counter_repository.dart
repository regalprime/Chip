import 'package:common_packages/domain/entities/day_counter/day_counter_entity.dart';

abstract class DayCounterRepository {
  Future<List<DayCounterEntity>> getDayCounters();
  Future<DayCounterEntity> addDayCounter({
    required String title,
    required DateTime targetDate,
    String emoji,
    String colorHex,
    String? note,
  });
  Future<DayCounterEntity> updateDayCounter({
    required String id,
    required String title,
    required DateTime targetDate,
    String emoji,
    String colorHex,
    String? note,
  });
  Future<void> deleteDayCounter({required String id});
}
