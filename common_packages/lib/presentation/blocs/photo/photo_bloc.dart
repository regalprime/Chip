import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/photo/photo_entity.dart';
import 'package:common_packages/domain/usecases/photo/delete_photos_use_case.dart';
import 'package:common_packages/domain/usecases/photo/get_photos_use_case.dart';
import 'package:common_packages/domain/usecases/photo/upload_photo_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'photo_event.dart';
part 'photo_state.dart';

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  PhotoBloc({
    required UploadPhotoUseCase uploadPhotoUseCase,
    required GetPhotosUseCase getPhotosUseCase,
    required DeletePhotosUseCase deletePhotosUseCase,
  })  : _uploadPhotoUseCase = uploadPhotoUseCase,
        _getPhotosUseCase = getPhotosUseCase,
        _deletePhotosUseCase = deletePhotosUseCase,
        super(const PhotoState()) {
    on<LoadPhotosEvent>(_onLoadPhotos);
    on<UploadPhotoEvent>(_onUploadPhoto);
    on<DeletePhotosEvent>(_onDeletePhotos);
    on<ToggleSelectionModeEvent>(_onToggleSelectionMode);
    on<TogglePhotoSelectionEvent>(_onTogglePhotoSelection);
    on<ClearSelectionEvent>(_onClearSelection);
  }

  final UploadPhotoUseCase _uploadPhotoUseCase;
  final GetPhotosUseCase _getPhotosUseCase;
  final DeletePhotosUseCase _deletePhotosUseCase;

  Future<void> _onLoadPhotos(
    LoadPhotosEvent event,
    Emitter<PhotoState> emit,
  ) async {
    emit(state.copyWith(status: PhotoStatus.loading));

    final result = await _getPhotosUseCase();

    result.when(
      success: (photos) {
        emit(state.copyWith(
          status: PhotoStatus.loaded,
          photos: photos,
        ));
      },
      failure: (failure) {
        emit(state.copyWith(
          status: PhotoStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }

  Future<void> _onUploadPhoto(
    UploadPhotoEvent event,
    Emitter<PhotoState> emit,
  ) async {
    emit(state.copyWith(status: PhotoStatus.uploading));

    final result = await _uploadPhotoUseCase(event.filePath);

    result.when(
      success: (photo) {
        emit(state.copyWith(
          status: PhotoStatus.loaded,
          photos: [photo, ...state.photos],
        ));
      },
      failure: (failure) {
        emit(state.copyWith(
          status: PhotoStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }

  Future<void> _onDeletePhotos(
    DeletePhotosEvent event,
    Emitter<PhotoState> emit,
  ) async {
    emit(state.copyWith(status: PhotoStatus.deleting));

    final result = await _deletePhotosUseCase(event.photoIds);

    result.when(
      success: (_) {
        final updatedPhotos = state.photos
            .where((p) => !event.photoIds.contains(p.id))
            .toList();
        emit(state.copyWith(
          status: PhotoStatus.loaded,
          photos: updatedPhotos,
          isSelectionMode: false,
          selectedPhotoIds: const {},
        ));
      },
      failure: (failure) {
        emit(state.copyWith(
          status: PhotoStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }

  void _onToggleSelectionMode(
    ToggleSelectionModeEvent event,
    Emitter<PhotoState> emit,
  ) {
    if (state.isSelectionMode) {
      emit(state.copyWith(
        isSelectionMode: false,
        selectedPhotoIds: const {},
      ));
    } else {
      emit(state.copyWith(isSelectionMode: true));
    }
  }

  void _onTogglePhotoSelection(
    TogglePhotoSelectionEvent event,
    Emitter<PhotoState> emit,
  ) {
    final selected = Set<String>.from(state.selectedPhotoIds);
    if (selected.contains(event.photoId)) {
      selected.remove(event.photoId);
    } else {
      selected.add(event.photoId);
    }
    emit(state.copyWith(
      selectedPhotoIds: selected,
      isSelectionMode: selected.isNotEmpty,
    ));
  }

  void _onClearSelection(
    ClearSelectionEvent event,
    Emitter<PhotoState> emit,
  ) {
    emit(state.copyWith(
      isSelectionMode: false,
      selectedPhotoIds: const {},
    ));
  }
}
