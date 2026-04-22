import 'package:equatable/equatable.dart';

class WishEntity extends Equatable {
  const WishEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.emoji = '⭐',
    this.isCompleted = false,
    this.completedAt,
    this.completionNote,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String? description;
  final String emoji;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completionNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id, userId, title, description, emoji,
        isCompleted, completedAt, completionNote, createdAt, updatedAt,
      ];
}
