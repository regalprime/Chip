import 'package:common_packages/domain/entities/wish/wish_entity.dart';

class WishModel extends WishEntity {
  const WishModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    super.emoji,
    super.isCompleted,
    super.completedAt,
    super.completionNote,
    super.createdAt,
    super.updatedAt,
  });

  factory WishModel.fromJson(Map<String, dynamic> json) {
    return WishModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      emoji: json['emoji'] as String? ?? '⭐',
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      completionNote: json['completion_note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
