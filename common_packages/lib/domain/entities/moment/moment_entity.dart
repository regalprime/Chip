import 'package:equatable/equatable.dart';

class MomentEntity extends Equatable {
  final String id;
  final String userId;
  final String? content;
  final String? imageUrl;
  final String? mood;
  final DateTime createdAt;
  // Denormalized from users join
  final String? userName;
  final String? userPhoto;
  // Reactions
  final List<MomentReactionEntity> reactions;

  const MomentEntity({
    required this.id,
    required this.userId,
    this.content,
    this.imageUrl,
    this.mood,
    required this.createdAt,
    this.userName,
    this.userPhoto,
    this.reactions = const [],
  });

  @override
  List<Object?> get props => [id, userId, content, imageUrl, mood, createdAt];
}

class MomentReactionEntity extends Equatable {
  final String id;
  final String momentId;
  final String userId;
  final String emoji;
  final DateTime createdAt;
  final String? userName;
  final String? userPhoto;

  const MomentReactionEntity({
    required this.id,
    required this.momentId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
    this.userName,
    this.userPhoto,
  });

  @override
  List<Object?> get props => [id, momentId, userId, emoji, createdAt];
}
