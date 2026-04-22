import 'package:equatable/equatable.dart';

enum FriendshipStatus { pending, accepted, rejected }

class FriendshipEntity extends Equatable {
  final String id;
  final String requesterId;
  final String addresseeId;
  final FriendshipStatus status;
  final DateTime createdAt;
  final String? requesterName;
  final String? requesterPhoto;
  final String? addresseeName;
  final String? addresseePhoto;

  const FriendshipEntity({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    required this.createdAt,
    this.requesterName,
    this.requesterPhoto,
    this.addresseeName,
    this.addresseePhoto,
  });

  @override
  List<Object?> get props => [id, requesterId, addresseeId, status, createdAt];
}
