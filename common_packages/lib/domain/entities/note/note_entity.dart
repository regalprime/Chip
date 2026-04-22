import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, content, userId, createdAt, updatedAt];
}
