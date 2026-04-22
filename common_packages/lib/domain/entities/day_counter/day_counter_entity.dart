import 'package:equatable/equatable.dart';

class DayCounterEntity extends Equatable {
  const DayCounterEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetDate,
    this.emoji = '❤️',
    this.colorHex = 'FFD32F2F',
    this.note,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final DateTime targetDate;
  final String emoji;
  final String colorHex;
  final String? note;
  final DateTime? createdAt;

  /// Positive = days passed since targetDate. Negative = days until targetDate.
  int get daysDiff {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return today.difference(target).inDays;
  }

  bool get isCountingUp => daysDiff >= 0;

  @override
  List<Object?> get props => [id, userId, title, targetDate, emoji, colorHex, note, createdAt];
}
