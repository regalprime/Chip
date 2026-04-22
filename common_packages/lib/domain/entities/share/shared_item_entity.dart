import 'package:equatable/equatable.dart';

enum SharedItemType { photo, note }

class SharedItemEntity extends Equatable {
  final String id;
  final String ownerId;
  final String sharedWithId;
  final SharedItemType itemType;
  final String itemId;
  final DateTime createdAt;
  final String? ownerName;
  final String? ownerPhoto;
  // Data trả về từ join
  final String? photoUrl;
  final String? noteTitle;
  final String? noteContent;

  const SharedItemEntity({
    required this.id,
    required this.ownerId,
    required this.sharedWithId,
    required this.itemType,
    required this.itemId,
    required this.createdAt,
    this.ownerName,
    this.ownerPhoto,
    this.photoUrl,
    this.noteTitle,
    this.noteContent,
  });

  @override
  List<Object?> get props => [id, ownerId, sharedWithId, itemType, itemId, createdAt];
}
