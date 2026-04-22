import 'package:common_packages/domain/entities/share/shared_item_entity.dart';

class SharedItemModel extends SharedItemEntity {
  const SharedItemModel({
    required super.id,
    required super.ownerId,
    required super.sharedWithId,
    required super.itemType,
    required super.itemId,
    required super.createdAt,
    super.ownerName,
    super.ownerPhoto,
    super.photoUrl,
    super.noteTitle,
    super.noteContent,
  });

  factory SharedItemModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;
    final photo = json['photo'] as Map<String, dynamic>?;
    final note = json['note'] as Map<String, dynamic>?;

    return SharedItemModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      sharedWithId: json['shared_with_id'] as String,
      itemType: json['item_type'] == 'photo'
          ? SharedItemType.photo
          : SharedItemType.note,
      itemId: json['item_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      ownerName: owner?['display_name'] as String?,
      ownerPhoto: owner?['photo_url'] as String?,
      photoUrl: photo?['url'] as String?,
      noteTitle: note?['title'] as String?,
      noteContent: note?['content'] as String?,
    );
  }
}
