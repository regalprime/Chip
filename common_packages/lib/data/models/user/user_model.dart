import 'package:common_packages/domain/entities/user/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.bio,
  });

  factory UserModel.fromFirebaseUser(Map<String, dynamic> user) {
    final uid = user['uid'];
    final email = user['email'];
    if (uid is! String || email is! String) {
      throw const FormatException('Invalid user data: uid or email missing');
    }
    return UserModel(
      uid: uid,
      email: email,
      displayName: user['displayName'] as String?,
      photoUrl: user['photoUrl'] as String?,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'bio': bio,
    };
  }
}
