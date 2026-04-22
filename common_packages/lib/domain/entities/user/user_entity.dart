import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? bio;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.bio,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, bio];
}