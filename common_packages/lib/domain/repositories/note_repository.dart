import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/note/note_entity.dart';

abstract class NoteRepository {
  Future<Result<List<NoteEntity>>> getNotes();
  Future<Result<NoteEntity>> addNote({required String title, required String content});
  Future<Result<NoteEntity>> updateNote({required String id, required String title, required String content});
  Future<Result<void>> deleteNote({required String id});
}
