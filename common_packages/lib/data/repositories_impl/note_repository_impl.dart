import 'package:common_packages/core/error/app_failure.dart';
import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/note/note_entity.dart';
import 'package:common_packages/domain/repositories/note_repository.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';

class NoteRepositoryImpl implements NoteRepository {
  const NoteRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<NoteEntity>>> getNotes() async {
    try {
      final notes = await _remoteDataSource.getNotes();
      return Success(notes);
    } catch (e) {
      return Failure(ServerFailure('Failed to get notes: $e'));
    }
  }

  @override
  Future<Result<NoteEntity>> addNote({required String title, required String content}) async {
    try {
      final note = await _remoteDataSource.addNote(title: title, content: content);
      return Success(note);
    } catch (e) {
      return Failure(ServerFailure('Failed to add note: $e'));
    }
  }

  @override
  Future<Result<NoteEntity>> updateNote({required String id, required String title, required String content}) async {
    try {
      final note = await _remoteDataSource.updateNote(id: id, title: title, content: content);
      return Success(note);
    } catch (e) {
      return Failure(ServerFailure('Failed to update note: $e'));
    }
  }

  @override
  Future<Result<void>> deleteNote({required String id}) async {
    try {
      await _remoteDataSource.deleteNote(id: id);
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to delete note: $e'));
    }
  }
}
