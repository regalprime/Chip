import 'package:common_packages/domain/entities/friendship/friendship_entity.dart';

class FriendshipModel extends FriendshipEntity {
  const FriendshipModel({
    required super.id,
    required super.requesterId,
    required super.addresseeId,
    required super.status,
    required super.createdAt,
    super.requesterName,
    super.requesterPhoto,
    super.addresseeName,
    super.addresseePhoto,
  });

  factory FriendshipModel.fromJson(Map<String, dynamic> json) {
    final requester = json['requester'] as Map<String, dynamic>?;
    final addressee = json['addressee'] as Map<String, dynamic>?;

    return FriendshipModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      addresseeId: json['addressee_id'] as String,
      status: FriendshipStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendshipStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      requesterName: requester?['display_name'] as String?,
      requesterPhoto: requester?['photo_url'] as String?,
      addresseeName: addressee?['display_name'] as String?,
      addresseePhoto: addressee?['photo_url'] as String?,
    );
  }
}
