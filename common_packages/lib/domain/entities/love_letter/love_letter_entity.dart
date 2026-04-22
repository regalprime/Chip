import 'package:equatable/equatable.dart';

class LoveLetterEntity extends Equatable {
  const LoveLetterEntity({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.title,
    required this.content,
    required this.deliveryDate,
    this.isRead = false,
    this.readAt,
    this.createdAt,
    this.senderName,
    this.senderPhoto,
    this.recipientName,
    this.recipientPhoto,
  });

  final String id;
  final String senderId;
  final String recipientId;
  final String title;
  final String content;
  final DateTime deliveryDate;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final String? senderName;
  final String? senderPhoto;
  final String? recipientName;
  final String? recipientPhoto;

  bool get isDelivered {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final delivery = DateTime(deliveryDate.year, deliveryDate.month, deliveryDate.day);
    return !today.isBefore(delivery);
  }

  int get daysUntilDelivery {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final delivery = DateTime(deliveryDate.year, deliveryDate.month, deliveryDate.day);
    return delivery.difference(today).inDays;
  }

  @override
  List<Object?> get props => [
        id, senderId, recipientId, title, content,
        deliveryDate, isRead, readAt, createdAt,
      ];
}
