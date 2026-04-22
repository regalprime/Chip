part of 'photo_bloc.dart';

enum PhotoStatus { initial, loading, uploading, deleting, loaded, error }

class PhotoState extends Equatable {
  final PhotoStatus status;
  final List<PhotoEntity> photos;
  final String? errorMessage;
  final bool isSelectionMode;
  final Set<String> selectedPhotoIds;

  const PhotoState({
    this.status = PhotoStatus.initial,
    this.photos = const [],
    this.errorMessage,
    this.isSelectionMode = false,
    this.selectedPhotoIds = const {},
  });

  PhotoState copyWith({
    PhotoStatus? status,
    List<PhotoEntity>? photos,
    String? errorMessage,
    bool? isSelectionMode,
    Set<String>? selectedPhotoIds,
  }) {
    return PhotoState(
      status: status ?? this.status,
      photos: photos ?? this.photos,
      errorMessage: errorMessage ?? this.errorMessage,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedPhotoIds: selectedPhotoIds ?? this.selectedPhotoIds,
    );
  }

  @override
  List<Object?> get props => [status, photos, errorMessage, isSelectionMode, selectedPhotoIds];
}
