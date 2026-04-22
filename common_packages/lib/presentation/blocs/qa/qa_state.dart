part of 'qa_bloc.dart';

enum QaStatus { initial, loading, loaded, submitting, error }

class QaState extends Equatable {
  const QaState({
    this.status = QaStatus.initial,
    this.todayQuestion,
    this.history = const [],
    this.selectedFriendshipId,
    this.selectedPartnerUid,
    this.selectedPartnerName,
    this.errorMessage,
  });

  final QaStatus status;
  final QaDailyEntity? todayQuestion;
  final List<QaDailyEntity> history;
  final String? selectedFriendshipId;
  final String? selectedPartnerUid;
  final String? selectedPartnerName;
  final String? errorMessage;

  QaState copyWith({
    QaStatus? status,
    QaDailyEntity? todayQuestion,
    List<QaDailyEntity>? history,
    String? selectedFriendshipId,
    String? selectedPartnerUid,
    String? selectedPartnerName,
    String? errorMessage,
  }) {
    return QaState(
      status: status ?? this.status,
      todayQuestion: todayQuestion ?? this.todayQuestion,
      history: history ?? this.history,
      selectedFriendshipId: selectedFriendshipId ?? this.selectedFriendshipId,
      selectedPartnerUid: selectedPartnerUid ?? this.selectedPartnerUid,
      selectedPartnerName: selectedPartnerName ?? this.selectedPartnerName,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status, todayQuestion, history,
        selectedFriendshipId, selectedPartnerUid, selectedPartnerName, errorMessage,
      ];
}
