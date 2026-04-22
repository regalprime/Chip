import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/note/note_entity.dart';
import 'package:common_packages/domain/repositories/note_repository.dart';

class UpdateNoteParams {
  final String id;
  final String title;
  final String content;

  const UpdateNoteParams({required this.id, required this.title, required this.content});
}

class UpdateNoteUseCase extends UseCase<NoteEntity, UpdateNoteParams> {
  final NoteRepository _repository;

  UpdateNoteUseCase(this._repository);

  @override
  Future<Result<NoteEntity>> call(UpdateNoteParams params) {
    return _repository.updateNote(id: params.id, title: params.title, content: params.content);
  }
}
