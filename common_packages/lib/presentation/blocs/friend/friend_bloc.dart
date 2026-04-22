import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/friendship/friendship_entity.dart';
import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/domain/usecases/friend/get_friend_requests_use_case.dart';
import 'package:common_packages/domain/usecases/friend/get_friends_use_case.dart';
import 'package:common_packages/domain/usecases/friend/remove_friend_use_case.dart';
import 'package:common_packages/domain/usecases/friend/respond_friend_request_use_case.dart';
import 'package:common_packages/domain/usecases/friend/search_users_use_case.dart';
import 'package:common_packages/domain/usecases/friend/send_friend_request_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'friend_event.dart';
part 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  FriendBloc({
    required SearchUsersUseCase searchUsersUseCase,
    required SendFriendRequestUseCase sendFriendRequestUseCase,
    required RespondFriendRequestUseCase respondFriendRequestUseCase,
    required GetFriendsUseCase getFriendsUseCase,
    required GetFriendRequestsUseCase getFriendRequestsUseCase,
    required RemoveFriendUseCase removeFriendUseCase,
  })  : _searchUsersUseCase = searchUsersUseCase,
        _sendFriendRequestUseCase = sendFriendRequestUseCase,
        _respondFriendRequestUseCase = respondFriendRequestUseCase,
        _getFriendsUseCase = getFriendsUseCase,
        _getFriendRequestsUseCase = getFriendRequestsUseCase,
        _removeFriendUseCase = removeFriendUseCase,
        super(const FriendState()) {
    on<LoadFriendsEvent>(_onLoadFriends);
    on<LoadFriendRequestsEvent>(_onLoadFriendRequests);
    on<SearchUsersEvent>(_onSearchUsers);
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<RespondFriendRequestEvent>(_onRespondFriendRequest);
    on<RemoveFriendEvent>(_onRemoveFriend);
  }

  final SearchUsersUseCase _searchUsersUseCase;
  final SendFriendRequestUseCase _sendFriendRequestUseCase;
  final RespondFriendRequestUseCase _respondFriendRequestUseCase;
  final GetFriendsUseCase _getFriendsUseCase;
  final GetFriendRequestsUseCase _getFriendRequestsUseCase;
  final RemoveFriendUseCase _removeFriendUseCase;

  Future<void> _onLoadFriends(
    LoadFriendsEvent event,
    Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.loading));

    final result = await _getFriendsUseCase();

    result.when(
      success: (friends) {
        emit(state.copyWith(status: FriendStatus.loaded, friends: friends));
      },
      failure: (failure) {
        emit(state.copyWith(status: FriendStatus.error, errorMessage: failure.message));
      },
    );
  }

  Future<void> _onLoadFriendRequests(
    LoadFriendRequestsEvent event,
    Emitter<FriendState> emit,
  ) async {
    final result = await _getFriendRequestsUseCase();

    result.when(
      success: (requests) {
        emit(state.copyWith(friendRequests: requests));
      },
      failure: (failure) {
        emit(state.copyWith(errorMessage: failure.message));
      },
    );
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<FriendState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(searchResults: const []));
      return;
    }

    emit(state.copyWith(status: FriendStatus.searching));

    final result = await _searchUsersUseCase(event.query);

    result.when(
      success: (users) {
        emit(state.copyWith(status: FriendStatus.loaded, searchResults: users));
      },
      failure: (failure) {
        emit(state.copyWith(status: FriendStatus.error, errorMessage: failure.message));
      },
    );
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequestEvent event,
    Emitter<FriendState> emit,
  ) async {
    final result = await _sendFriendRequestUseCase(event.addresseeId);

    result.when(
      success: (_) {
        emit(state.copyWith(status: FriendStatus.requestSent));
        // Reload lại sau khi gửi request
        add(const LoadFriendsEvent());
      },
      failure: (failure) {
        emit(state.copyWith(status: FriendStatus.error, errorMessage: failure.message));
      },
    );
  }

  Future<void> _onRespondFriendRequest(
    RespondFriendRequestEvent event,
    Emitter<FriendState> emit,
  ) async {
    final result = await _respondFriendRequestUseCase(
      RespondFriendRequestParams(friendshipId: event.friendshipId, accept: event.accept),
    );

    result.when(
      success: (_) {
        final updatedRequests = state.friendRequests
            .where((r) => r.id != event.friendshipId)
            .toList();
        emit(state.copyWith(friendRequests: updatedRequests));
        // Reload friends nếu accept
        if (event.accept) {
          add(const LoadFriendsEvent());
        }
      },
      failure: (failure) {
        emit(state.copyWith(status: FriendStatus.error, errorMessage: failure.message));
      },
    );
  }

  Future<void> _onRemoveFriend(
    RemoveFriendEvent event,
    Emitter<FriendState> emit,
  ) async {
    final result = await _removeFriendUseCase(event.friendshipId);

    result.when(
      success: (_) {
        final updatedFriends = state.friends
            .where((f) => f.id != event.friendshipId)
            .toList();
        emit(state.copyWith(friends: updatedFriends));
      },
      failure: (failure) {
        emit(state.copyWith(status: FriendStatus.error, errorMessage: failure.message));
      },
    );
  }
}
