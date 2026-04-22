import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/note/note_entity.dart';
import 'package:common_packages/domain/usecases/note/add_note_use_case.dart';
import 'package:common_packages/domain/usecases/note/delete_note_use_case.dart';
import 'package:common_packages/domain/usecases/note/get_notes_use_case.dart';
import 'package:common_packages/domain/usecases/note/update_note_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc({
    required GetNotesUseCase getNotesUseCase,
    required AddNoteUseCase addNoteUseCase,
    required UpdateNoteUseCase updateNoteUseCase,
    required DeleteNoteUseCase deleteNoteUseCase,
  })  : _getNotesUseCase = getNotesUseCase,
        _addNoteUseCase = addNoteUseCase,
        _updateNoteUseCase = updateNoteUseCase,
        _deleteNoteUseCase = deleteNoteUseCase,
        super(const NoteState()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
  }

  final GetNotesUseCase _getNotesUseCase;
  final AddNoteUseCase _addNoteUseCase;
  final UpdateNoteUseCase _updateNoteUseCase;
  final DeleteNoteUseCase _deleteNoteUseCase;

  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(status: NoteStatus.loading));

    final result = await _getNotesUseCase();

    result.when(
      success: (notes) {
        emit(state.copyWith(
          status: NoteStatus.loaded,
          notes: notes,
        ));
      },
      failure: (failure) {
        emit(state.copyWith(
          status: NoteStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }

  Future<void> _onAddNote(
    AddNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(status: NoteStatus.saving));

    final result = await _addNoteUseCase(
      AddNoteParams(title: event.title, content: event.content),
    );

    result.when(
      success: (note) {
        emit(state.copyWith(
          status: NoteStatus.loaded,
          notes: [note, ...state.notes],
        ));
      },
      failure: (failure) {
        emit(state.copyWith(
          status: NoteStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }

  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(status: NoteStatus.saving));

    final result = await _updateNoteUseCase(
      UpdateNoteParams(id: event.id, title: event.title, content: event.content),
    );

    result.when(
      success: (updatedNote) {
        final updatedNotes = state.notes
            .map((n) => n.id == updatedNote.id ? updatedNote : n)
            .toList();
        emit(state.copyWith(
          status: NoteStatus.loaded,
          notes: updatedNotes,
        ));
      },
      failure: (failure) {
        emit(state.copyWith(
          status: NoteStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }

  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(status: NoteStatus.saving));

    final result = await _deleteNoteUseCase(event.id);

    result.when(
      success: (_) {
        final updatedNotes = state.notes.where((n) => n.id != event.id).toList();
        emit(state.copyWith(
          status: NoteStatus.loaded,
          notes: updatedNotes,
        ));
      },
      failure: (failure) {
        emit(state.copyWith(
          status: NoteStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }
}
