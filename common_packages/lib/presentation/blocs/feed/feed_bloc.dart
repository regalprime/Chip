import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/share/shared_item_entity.dart';
import 'package:common_packages/domain/usecases/share/get_shared_feed_use_case.dart';
import 'package:common_packages/domain/usecases/share/share_item_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({
    required GetSharedFeedUseCase getSharedFeedUseCase,
    required ShareItemUseCase shareItemUseCase,
  })  : _getSharedFeedUseCase = getSharedFeedUseCase,
        _shareItemUseCase = shareItemUseCase,
        super(const FeedState()) {
    on<LoadFeedEvent>(_onLoadFeed);
    on<ShareItemEvent>(_onShareItem);
  }

  final GetSharedFeedUseCase _getSharedFeedUseCase;
  final ShareItemUseCase _shareItemUseCase;

  Future<void> _onLoadFeed(
    LoadFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading));

    final result = await _getSharedFeedUseCase();

    result.when(
      success: (items) {
        emit(state.copyWith(status: FeedStatus.loaded, items: items));
      },
      failure: (failure) {
        emit(state.copyWith(status: FeedStatus.error, errorMessage: failure.message));
      },
    );
  }

  Future<void> _onShareItem(
    ShareItemEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.sharing));

    final result = await _shareItemUseCase(ShareItemParams(
      friendId: event.friendId,
      itemId: event.itemId,
      itemType: event.itemType,
    ));

    result.when(
      success: (_) {
        emit(state.copyWith(status: FeedStatus.shared));
      },
      failure: (failure) {
        emit(state.copyWith(status: FeedStatus.error, errorMessage: failure.message));
      },
    );
  }
}
