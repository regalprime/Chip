import 'package:common_packages/domain/entities/moment/moment_entity.dart';

class MomentModel extends MomentEntity {
  const MomentModel({
    required super.id,
    required super.userId,
    super.content,
    super.imageUrl,
    super.mood,
    required super.createdAt,
    super.userName,
    super.userPhoto,
    super.reactions,
  });

  factory MomentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final reactionsJson = json['moment_reactions'] as List<dynamic>? ?? [];

    return MomentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      mood: json['mood'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: user?['display_name'] as String?,
      userPhoto: user?['photo_url'] as String?,
      reactions: reactionsJson
          .map((r) => MomentReactionModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MomentReactionModel extends MomentReactionEntity {
  const MomentReactionModel({
    required super.id,
    required super.momentId,
    required super.userId,
    required super.emoji,
    required super.createdAt,
    super.userName,
    super.userPhoto,
  });

  factory MomentReactionModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;

    return MomentReactionModel(
      id: json['id'] as String,
      momentId: json['moment_id'] as String,
      userId: json['user_id'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: user?['display_name'] as String?,
      userPhoto: user?['photo_url'] as String?,
    );
  }
}
