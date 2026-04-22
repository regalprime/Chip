import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/note/note_entity.dart';
import 'package:common_packages/domain/repositories/note_repository.dart';

class GetNotesUseCase extends UseCaseNoParams<List<NoteEntity>> {
  final NoteRepository _repository;

  GetNotesUseCase(this._repository);

  @override
  Future<Result<List<NoteEntity>>> call() {
    return _repository.getNotes();
  }
}
