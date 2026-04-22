import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/moment/moment_entity.dart';
import 'package:common_packages/domain/usecases/moment/delete_moment_use_case.dart';
import 'package:common_packages/domain/usecases/moment/get_moments_use_case.dart';
import 'package:common_packages/domain/usecases/moment/react_to_moment_use_case.dart';
import 'package:common_packages/domain/usecases/moment/send_moment_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'moment_event.dart';
part 'moment_state.dart';

class MomentBloc extends Bloc<MomentEvent, MomentState> {
  MomentBloc({
    required GetMomentsUseCase getMomentsUseCase,
    required SendMomentUseCase sendMomentUseCase,
    required ReactToMomentUseCase reactToMomentUseCase,
    required DeleteMomentUseCase deleteMomentUseCase,
  })  : _getMomentsUseCase = getMomentsUseCase,
        _sendMomentUseCase = sendMomentUseCase,
        _reactToMomentUseCase = reactToMomentUseCase,
        _deleteMomentUseCase = deleteMomentUseCase,
        super(const MomentState()) {
    on<LoadMomentsEvent>(_onLoadMoments);
    on<SendMomentEvent>(_onSendMoment);
    on<ReactToMomentEvent>(_onReactToMoment);
    on<DeleteMomentEvent>(_onDeleteMoment);
  }

  final GetMomentsUseCase _getMomentsUseCase;
  final SendMomentUseCase _sendMomentUseCase;
  final ReactToMomentUseCase _reactToMomentUseCase;
  final DeleteMomentUseCase _deleteMomentUseCase;

  Future<void> _onLoadMoments(
    LoadMomentsEvent event,
    Emitter<MomentState> emit,
  ) async {
    emit(state.copyWith(status: MomentStatus.loading));

    final result = await _getMomentsUseCase();

    result.when(
      success: (moments) {
        emit(state.copyWith(status: MomentStatus.loaded, moments: moments));
      },
      failure: (failure) {
        emit(state.copyWith(status: MomentStatus.error, errorMessage: failure.message));
      },
    );
  }

  Future<void> _onSendMoment(
    SendMomentEvent event,
    Emitter<MomentState> emit,
  ) async {
    emit(state.copyWith(status: MomentStatus.sending));

    final result = await _sendMomentUseCase(SendMomentParams(
      content: event.content,
      imagePath: event.imagePath,
      mood: event.mood,
    ));

    result.when(
      success: (moment) {
        final updatedMoments = [moment, ...state.moments];
        emit(state.copyWith(status: MomentStatus.sent, moments: updatedMoments));
      },
      failure: (failure) {
        emit(state.copyWith(status: MomentStatus.error, errorMessage: failure.message));
      },
    );
  }

  Future<void> _onReactToMoment(
    ReactToMomentEvent event,
    Emitter<MomentState> emit,
  ) async {
    final result = await _reactToMomentUseCase(ReactToMomentParams(
      momentId: event.momentId,
      emoji: event.emoji,
    ));

    result.when(
      success: (reaction) {
        // Update reaction in moment list
        final updatedMoments = state.moments.map((m) {
          if (m.id == event.momentId) {
            final reactions = [...m.reactions];
            final existingIndex = reactions.indexWhere((r) => r.userId == reaction.userId);
            if (existingIndex >= 0) {
              reactions[existingIndex] = reaction;
            } else {
              reactions.add(reaction);
            }
            return MomentEntity(
              id: m.id,
              userId: m.userId,
              content: m.content,
              imageUrl: m.imageUrl,
              mood: m.mood,
              createdAt: m.createdAt,
              userName: m.userName,
              userPhoto: m.userPhoto,
              reactions: reactions,
            );
          }
          return m;
        }).toList();
        emit(state.copyWith(status: MomentStatus.loaded, moments: updatedMoments));
      },
      failure: (failure) {
        emit(state.copyWith(status: MomentStatus.error, errorMessage: failure.message));
      },
    );
  }

  Future<void> _onDeleteMoment(
    DeleteMomentEvent event,
    Emitter<MomentState> emit,
  ) async {
    final result = await _deleteMomentUseCase(event.momentId);

    result.when(
      success: (_) {
        final updatedMoments = state.moments.where((m) => m.id != event.momentId).toList();
        emit(state.copyWith(status: MomentStatus.loaded, moments: updatedMoments));
      },
      failure: (failure) {
        emit(state.copyWith(status: MomentStatus.error, errorMessage: failure.message));
      },
    );
  }
}
