import 'package:common_packages/domain/entities/day_counter/day_milestone.dart';

class CalculateMilestonesUseCase {
  static const List<int> _milestoneTargets = [100, 365, 500, 1000, 1500, 2000];

  List<DayMilestone> call(int daysDiff) {
    return _milestoneTargets.map((target) {
      final remaining = target - daysDiff;
      return DayMilestone(
        targetDays: target,
        daysRemaining: remaining > 0 ? remaining : 0,
      );
    }).toList();
  }
}
