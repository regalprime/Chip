class DayMilestone {
  const DayMilestone({required this.targetDays, required this.daysRemaining});

  final int targetDays;
  final int daysRemaining;
  bool get isReached => daysRemaining <= 0;
}
