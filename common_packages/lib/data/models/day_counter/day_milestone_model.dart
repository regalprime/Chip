import 'package:common_packages/domain/entities/day_counter/day_milestone.dart';

class DayMilestoneModel extends DayMilestone {
  const DayMilestoneModel({required super.targetDays, required super.daysRemaining});

  factory DayMilestoneModel.fromEntity(DayMilestone entity) =>
      DayMilestoneModel(targetDays: entity.targetDays, daysRemaining: entity.daysRemaining);

  factory DayMilestoneModel.fromJson(Map<String, dynamic> json) =>
      DayMilestoneModel(targetDays: json['target_days'] as int, daysRemaining: json['days_remaining'] as int);

  Map<String, dynamic> toJson() => {'target_days': targetDays, 'days_remaining': daysRemaining};
}
