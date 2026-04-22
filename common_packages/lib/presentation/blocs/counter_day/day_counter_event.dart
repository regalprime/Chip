part of 'day_counter_bloc.dart';

sealed class DayCounterEvent extends Equatable {
  const DayCounterEvent();

  @override
  List<Object?> get props => [];
}

class LoadDayCountersEvent extends DayCounterEvent {
  const LoadDayCountersEvent();
}

class AddDayCounterEvent extends DayCounterEvent {
  const AddDayCounterEvent({
    required this.title,
    required this.targetDate,
    this.emoji = '❤️',
    this.colorHex = 'FFD32F2F',
    this.note,
  });

  final String title;
  final DateTime targetDate;
  final String emoji;
  final String colorHex;
  final String? note;

  @override
  List<Object?> get props => [title, targetDate, emoji, colorHex, note];
}

class UpdateDayCounterEvent extends DayCounterEvent {
  const UpdateDayCounterEvent({
    required this.id,
    required this.title,
    required this.targetDate,
    this.emoji = '❤️',
    this.colorHex = 'FFD32F2F',
    this.note,
  });

  final String id;
  final String title;
  final DateTime targetDate;
  final String emoji;
  final String colorHex;
  final String? note;

  @override
  List<Object?> get props => [id, title, targetDate, emoji, colorHex, note];
}

class DeleteDayCounterEvent extends DayCounterEvent {
  const DeleteDayCounterEvent({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
