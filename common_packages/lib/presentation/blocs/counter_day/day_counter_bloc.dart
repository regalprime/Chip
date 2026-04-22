import 'package:common_packages/domain/entities/day_counter/day_counter_entity.dart';
import 'package:common_packages/domain/repositories/day_counter_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'day_counter_event.dart';
part 'day_counter_state.dart';

class DayCounterBloc extends Bloc<DayCounterEvent, DayCounterState> {
  DayCounterBloc({
    required DayCounterRepository dayCounterRepository,
  })  : _repository = dayCounterRepository,
        super(const DayCounterState()) {
    on<LoadDayCountersEvent>(_onLoad);
    on<AddDayCounterEvent>(_onAdd);
    on<UpdateDayCounterEvent>(_onUpdate);
    on<DeleteDayCounterEvent>(_onDelete);
  }

  final DayCounterRepository _repository;

  Future<void> _onLoad(
    LoadDayCountersEvent event,
    Emitter<DayCounterState> emit,
  ) async {
    emit(state.copyWith(status: DayCounterStatus.loading));
    try {
      final counters = await _repository.getDayCounters();
      emit(state.copyWith(
        status: DayCounterStatus.loaded,
        counters: counters,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DayCounterStatus.error,
        errorMessage: 'Failed to load counters: $e',
      ));
    }
  }

  Future<void> _onAdd(
    AddDayCounterEvent event,
    Emitter<DayCounterState> emit,
  ) async {
    try {
      final counter = await _repository.addDayCounter(
        title: event.title,
        targetDate: event.targetDate,
        emoji: event.emoji,
        colorHex: event.colorHex,
        note: event.note,
      );
      emit(state.copyWith(
        counters: [counter, ...state.counters],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DayCounterStatus.error,
        errorMessage: 'Failed to add counter: $e',
      ));
    }
  }

  Future<void> _onUpdate(
    UpdateDayCounterEvent event,
    Emitter<DayCounterState> emit,
  ) async {
    try {
      final updated = await _repository.updateDayCounter(
        id: event.id,
        title: event.title,
        targetDate: event.targetDate,
        emoji: event.emoji,
        colorHex: event.colorHex,
        note: event.note,
      );
      final counters = state.counters.map((c) {
        return c.id == event.id ? updated : c;
      }).toList();
      emit(state.copyWith(counters: counters));
    } catch (e) {
      emit(state.copyWith(
        status: DayCounterStatus.error,
        errorMessage: 'Failed to update counter: $e',
      ));
    }
  }

  Future<void> _onDelete(
    DeleteDayCounterEvent event,
    Emitter<DayCounterState> emit,
  ) async {
    try {
      await _repository.deleteDayCounter(id: event.id);
      final counters = state.counters.where((c) => c.id != event.id).toList();
      emit(state.copyWith(counters: counters));
    } catch (e) {
      emit(state.copyWith(
        status: DayCounterStatus.error,
        errorMessage: 'Failed to delete counter: $e',
      ));
    }
  }
}
