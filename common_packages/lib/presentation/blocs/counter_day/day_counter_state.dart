part of 'day_counter_bloc.dart';

enum DayCounterStatus { initial, loading, loaded, error }

class DayCounterState extends Equatable {
  const DayCounterState({
    this.status = DayCounterStatus.initial,
    this.counters = const [],
    this.errorMessage,
  });

  final DayCounterStatus status;
  final List<DayCounterEntity> counters;
  final String? errorMessage;

  DayCounterState copyWith({
    DayCounterStatus? status,
    List<DayCounterEntity>? counters,
    String? errorMessage,
  }) {
    return DayCounterState(
      status: status ?? this.status,
      counters: counters ?? this.counters,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, counters, errorMessage];
}
