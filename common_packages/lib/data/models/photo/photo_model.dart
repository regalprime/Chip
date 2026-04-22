import 'package:common_packages/domain/entities/photo/photo_entity.dart';

class PhotoModel extends PhotoEntity {
  const PhotoModel({
    required super.id,
    required super.url,
    required super.userId,
    required super.createdAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String,
      url: json['url'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
