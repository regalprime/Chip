part of 'moment_bloc.dart';

enum MomentStatus { initial, loading, loaded, sending, sent, error }

class MomentState extends Equatable {
  final MomentStatus status;
  final List<MomentEntity> moments;
  final String? errorMessage;

  const MomentState({
    this.status = MomentStatus.initial,
    this.moments = const [],
    this.errorMessage,
  });

  MomentState copyWith({
    MomentStatus? status,
    List<MomentEntity>? moments,
    String? errorMessage,
  }) {
    return MomentState(
      status: status ?? this.status,
      moments: moments ?? this.moments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, moments, errorMessage];
}
