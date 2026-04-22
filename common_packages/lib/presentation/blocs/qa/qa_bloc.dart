import 'package:common_packages/domain/entities/qa/qa_answer_entity.dart';
import 'package:common_packages/domain/entities/qa/qa_daily_entity.dart';
import 'package:common_packages/domain/repositories/qa_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'qa_event.dart';
part 'qa_state.dart';

class QaBloc extends Bloc<QaEvent, QaState> {
  QaBloc({required QaRepository qaRepository})
      : _repository = qaRepository,
        super(const QaState()) {
    on<SelectFriendForQaEvent>(_onSelectFriend);
    on<LoadTodayQuestionEvent>(_onLoadToday);
    on<SubmitQaAnswerEvent>(_onSubmit);
    on<LoadQaHistoryEvent>(_onLoadHistory);
  }

  final QaRepository _repository;

  Future<void> _onSelectFriend(SelectFriendForQaEvent event, Emitter<QaState> emit) async {
    emit(state.copyWith(
      selectedFriendshipId: event.friendshipId,
      selectedPartnerUid: event.partnerUid,
      selectedPartnerName: event.partnerName,
    ));
    add(LoadTodayQuestionEvent(friendshipId: event.friendshipId, partnerUid: event.partnerUid));
  }

  Future<void> _onLoadToday(LoadTodayQuestionEvent event, Emitter<QaState> emit) async {
    emit(state.copyWith(status: QaStatus.loading));
    try {
      final daily = await _repository.getTodayQuestion(
        friendshipId: event.friendshipId,
        partnerUid: event.partnerUid,
      );
      emit(state.copyWith(status: QaStatus.loaded, todayQuestion: daily));
    } catch (e) {
      emit(state.copyWith(status: QaStatus.error, errorMessage: 'Khong the tai cau hoi: $e'));
    }
  }

  Future<void> _onSubmit(SubmitQaAnswerEvent event, Emitter<QaState> emit) async {
    emit(state.copyWith(status: QaStatus.submitting));
    try {
      await _repository.submitAnswer(
        friendshipId: event.friendshipId,
        questionIndex: event.questionIndex,
        questionDate: event.questionDate,
        answerText: event.answerText,
      );
      // Reload today's question to get updated state
      final daily = await _repository.getTodayQuestion(
        friendshipId: state.selectedFriendshipId!,
        partnerUid: state.selectedPartnerUid!,
      );
      emit(state.copyWith(status: QaStatus.loaded, todayQuestion: daily));
    } catch (e) {
      emit(state.copyWith(status: QaStatus.error, errorMessage: 'Gui cau tra loi that bai: $e'));
    }
  }

  Future<void> _onLoadHistory(LoadQaHistoryEvent event, Emitter<QaState> emit) async {
    try {
      final history = await _repository.getQaHistory(
        friendshipId: event.friendshipId,
        partnerUid: event.partnerUid,
      );
      emit(state.copyWith(history: history));
    } catch (e) {
      emit(state.copyWith(status: QaStatus.error, errorMessage: 'Khong the tai lich su: $e'));
    }
  }
}
