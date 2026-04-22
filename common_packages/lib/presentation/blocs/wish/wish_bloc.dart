import 'package:common_packages/domain/entities/wish/wish_entity.dart';
import 'package:common_packages/domain/repositories/wish_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'wish_event.dart';
part 'wish_state.dart';

class WishBloc extends Bloc<WishEvent, WishState> {
  WishBloc({required WishRepository wishRepository})
      : _repository = wishRepository,
        super(const WishState()) {
    on<LoadWishesEvent>(_onLoad);
    on<AddWishEvent>(_onAdd);
    on<UpdateWishEvent>(_onUpdate);
    on<CompleteWishEvent>(_onComplete);
    on<UncompleteWishEvent>(_onUncomplete);
    on<DeleteWishEvent>(_onDelete);
  }

  final WishRepository _repository;

  Future<void> _onLoad(LoadWishesEvent event, Emitter<WishState> emit) async {
    emit(state.copyWith(status: WishStatus.loading));
    try {
      final wishes = await _repository.getWishes();
      emit(state.copyWith(status: WishStatus.loaded, wishes: wishes));
    } catch (e) {
      emit(state.copyWith(status: WishStatus.error, errorMessage: 'Khong the tai danh sach: $e'));
    }
  }

  Future<void> _onAdd(AddWishEvent event, Emitter<WishState> emit) async {
    try {
      final wish = await _repository.addWish(
        title: event.title,
        description: event.description,
        emoji: event.emoji,
      );
      emit(state.copyWith(wishes: [wish, ...state.wishes]));
    } catch (e) {
      emit(state.copyWith(status: WishStatus.error, errorMessage: 'Them dieu uoc that bai: $e'));
    }
  }

  Future<void> _onUpdate(UpdateWishEvent event, Emitter<WishState> emit) async {
    try {
      final updated = await _repository.updateWish(
        id: event.id,
        title: event.title,
        description: event.description,
        emoji: event.emoji,
      );
      final wishes = state.wishes.map((w) => w.id == event.id ? updated : w).toList();
      emit(state.copyWith(wishes: wishes));
    } catch (e) {
      emit(state.copyWith(status: WishStatus.error, errorMessage: 'Cap nhat that bai: $e'));
    }
  }

  Future<void> _onComplete(CompleteWishEvent event, Emitter<WishState> emit) async {
    try {
      final completed = await _repository.completeWish(id: event.id, completionNote: event.completionNote);
      final wishes = state.wishes.map((w) => w.id == event.id ? completed : w).toList();
      emit(state.copyWith(wishes: wishes));
    } catch (e) {
      emit(state.copyWith(status: WishStatus.error, errorMessage: 'Hoan thanh that bai: $e'));
    }
  }

  Future<void> _onUncomplete(UncompleteWishEvent event, Emitter<WishState> emit) async {
    try {
      final uncompleted = await _repository.uncompleteWish(id: event.id);
      final wishes = state.wishes.map((w) => w.id == event.id ? uncompleted : w).toList();
      emit(state.copyWith(wishes: wishes));
    } catch (e) {
      emit(state.copyWith(status: WishStatus.error, errorMessage: 'Huy hoan thanh that bai: $e'));
    }
  }

  Future<void> _onDelete(DeleteWishEvent event, Emitter<WishState> emit) async {
    try {
      await _repository.deleteWish(id: event.id);
      final wishes = state.wishes.where((w) => w.id != event.id).toList();
      emit(state.copyWith(wishes: wishes));
    } catch (e) {
      emit(state.copyWith(status: WishStatus.error, errorMessage: 'Xoa that bai: $e'));
    }
  }
}
