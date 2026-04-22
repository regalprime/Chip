part of 'photo_bloc.dart';

sealed class PhotoEvent extends Equatable {
  const PhotoEvent();

  @override
  List<Object?> get props => [];
}

class LoadPhotosEvent extends PhotoEvent {
  const LoadPhotosEvent();
}

class UploadPhotoEvent extends PhotoEvent {
  final String filePath;

  const UploadPhotoEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class DeletePhotosEvent extends PhotoEvent {
  final List<String> photoIds;

  const DeletePhotosEvent(this.photoIds);

  @override
  List<Object?> get props => [photoIds];
}

class ToggleSelectionModeEvent extends PhotoEvent {
  const ToggleSelectionModeEvent();
}

class TogglePhotoSelectionEvent extends PhotoEvent {
  final String photoId;

  const TogglePhotoSelectionEvent(this.photoId);

  @override
  List<Object?> get props => [photoId];
}

class ClearSelectionEvent extends PhotoEvent {
  const ClearSelectionEvent();
}
