import 'package:common_packages/domain/entities/day_counter/day_counter_entity.dart';

class DayCounterModel extends DayCounterEntity {
  const DayCounterModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.targetDate,
    super.emoji,
    super.colorHex,
    super.note,
    super.createdAt,
  });

  factory DayCounterModel.fromJson(Map<String, dynamic> json) {
    return DayCounterModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      targetDate: DateTime.parse(json['target_date'] as String),
      emoji: json['emoji'] as String? ?? '❤️',
      colorHex: json['color_hex'] as String? ?? 'FFD32F2F',
      note: json['note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'target_date': '${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}',
      'emoji': emoji,
      'color_hex': colorHex,
      'note': note,
    };
  }
}
