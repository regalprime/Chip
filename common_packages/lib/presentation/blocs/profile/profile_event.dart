part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String displayName;
  final String? bio;
  final String? avatarFilePath;

  const UpdateProfileEvent({
    required this.displayName,
    this.bio,
    this.avatarFilePath,
  });

  @override
  List<Object?> get props => [displayName, bio, avatarFilePath];
}
