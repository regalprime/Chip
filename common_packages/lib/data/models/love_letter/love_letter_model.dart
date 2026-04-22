import 'package:common_packages/domain/entities/love_letter/love_letter_entity.dart';

class LoveLetterModel extends LoveLetterEntity {
  const LoveLetterModel({
    required super.id,
    required super.senderId,
    required super.recipientId,
    required super.title,
    required super.content,
    required super.deliveryDate,
    super.isRead,
    super.readAt,
    super.createdAt,
    super.senderName,
    super.senderPhoto,
    super.recipientName,
    super.recipientPhoto,
  });

  factory LoveLetterModel.fromJson(Map<String, dynamic> json) {
    // Handle joined sender/recipient user data
    final sender = json['sender'] as Map<String, dynamic>?;
    final recipient = json['recipient'] as Map<String, dynamic>?;

    return LoveLetterModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      recipientId: json['recipient_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      deliveryDate: DateTime.parse(json['delivery_date'] as String),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      senderName: sender?['display_name'] as String?,
      senderPhoto: sender?['photo_url'] as String?,
      recipientName: recipient?['display_name'] as String?,
      recipientPhoto: recipient?['photo_url'] as String?,
    );
  }
}
