part of 'note_bloc.dart';

sealed class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotesEvent extends NoteEvent {
  const LoadNotesEvent();
}

class AddNoteEvent extends NoteEvent {
  final String title;
  final String content;

  const AddNoteEvent({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class UpdateNoteEvent extends NoteEvent {
  final String id;
  final String title;
  final String content;

  const UpdateNoteEvent({required this.id, required this.title, required this.content});

  @override
  List<Object?> get props => [id, title, content];
}

class DeleteNoteEvent extends NoteEvent {
  final String id;

  const DeleteNoteEvent(this.id);

  @override
  List<Object?> get props => [id];
}
