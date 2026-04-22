import 'package:common_packages/domain/entities/love_letter/love_letter_entity.dart';
import 'package:common_packages/domain/repositories/love_letter_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'love_letter_event.dart';
part 'love_letter_state.dart';

class LoveLetterBloc extends Bloc<LoveLetterEvent, LoveLetterState> {
  LoveLetterBloc({required LoveLetterRepository loveLetterRepository})
      : _repository = loveLetterRepository,
        super(const LoveLetterState()) {
    on<LoadSentLettersEvent>(_onLoadSent);
    on<LoadReceivedLettersEvent>(_onLoadReceived);
    on<SendLetterEvent>(_onSend);
    on<MarkLetterReadEvent>(_onMarkRead);
    on<DeleteLetterEvent>(_onDelete);
  }

  final LoveLetterRepository _repository;

  Future<void> _onLoadSent(LoadSentLettersEvent event, Emitter<LoveLetterState> emit) async {
    emit(state.copyWith(status: LoveLetterStatus.loading));
    try {
      final letters = await _repository.getSentLetters();
      emit(state.copyWith(status: LoveLetterStatus.loaded, sentLetters: letters));
    } catch (e) {
      emit(state.copyWith(status: LoveLetterStatus.error, errorMessage: 'Khong the tai thu da gui: $e'));
    }
  }

  Future<void> _onLoadReceived(LoadReceivedLettersEvent event, Emitter<LoveLetterState> emit) async {
    emit(state.copyWith(status: LoveLetterStatus.loading));
    try {
      final letters = await _repository.getReceivedLetters();
      emit(state.copyWith(status: LoveLetterStatus.loaded, receivedLetters: letters));
    } catch (e) {
      emit(state.copyWith(status: LoveLetterStatus.error, errorMessage: 'Khong the tai thu da nhan: $e'));
    }
  }

  Future<void> _onSend(SendLetterEvent event, Emitter<LoveLetterState> emit) async {
    emit(state.copyWith(status: LoveLetterStatus.saving));
    try {
      final letter = await _repository.sendLetter(
        recipientId: event.recipientId,
        title: event.title,
        content: event.content,
        deliveryDate: event.deliveryDate,
      );
      emit(state.copyWith(
        status: LoveLetterStatus.loaded,
        sentLetters: [letter, ...state.sentLetters],
      ));
    } catch (e) {
      emit(state.copyWith(status: LoveLetterStatus.error, errorMessage: 'Gui thu that bai: $e'));
    }
  }

  Future<void> _onMarkRead(MarkLetterReadEvent event, Emitter<LoveLetterState> emit) async {
    try {
      final updated = await _repository.markAsRead(id: event.id);
      final received = state.receivedLetters.map((l) => l.id == event.id ? updated : l).toList();
      emit(state.copyWith(receivedLetters: received));
    } catch (e) {
      emit(state.copyWith(status: LoveLetterStatus.error, errorMessage: 'Khong the danh dau da doc: $e'));
    }
  }

  Future<void> _onDelete(DeleteLetterEvent event, Emitter<LoveLetterState> emit) async {
    try {
      await _repository.deleteLetter(id: event.id);
      final sent = state.sentLetters.where((l) => l.id != event.id).toList();
      emit(state.copyWith(sentLetters: sent));
    } catch (e) {
      emit(state.copyWith(status: LoveLetterStatus.error, errorMessage: 'Xoa thu that bai: $e'));
    }
  }
}
