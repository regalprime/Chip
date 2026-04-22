import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/repositories/note_repository.dart';

class DeleteNoteUseCase extends UseCase<void, String> {
  final NoteRepository _repository;

  DeleteNoteUseCase(this._repository);

  @override
  Future<Result<void>> call(String id) {
    return _repository.deleteNote(id: id);
  }
}
