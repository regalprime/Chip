import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/domain/usecases/profile/get_profile_use_case.dart';
import 'package:common_packages/domain/usecases/profile/update_profile_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await _getProfileUseCase();

    result.when(
      success: (user) {
        emit(state.copyWith(status: ProfileStatus.loaded, user: user));
      },
      failure: (failure) {
        emit(state.copyWith(status: ProfileStatus.error, errorMessage: failure.message));
      },
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.saving));

    final result = await _updateProfileUseCase(UpdateProfileParams(
      displayName: event.displayName,
      bio: event.bio,
      avatarFilePath: event.avatarFilePath,
    ));

    result.when(
      success: (user) {
        emit(state.copyWith(status: ProfileStatus.saved, user: user));
      },
      failure: (failure) {
        emit(state.copyWith(status: ProfileStatus.error, errorMessage: failure.message));
      },
    );
  }
}
