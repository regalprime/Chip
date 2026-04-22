import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/note/note_entity.dart';
import 'package:common_packages/domain/repositories/note_repository.dart';

class AddNoteParams {
  final String title;
  final String content;

  const AddNoteParams({required this.title, required this.content});
}

class AddNoteUseCase extends UseCase<NoteEntity, AddNoteParams> {
  final NoteRepository _repository;

  AddNoteUseCase(this._repository);

  @override
  Future<Result<NoteEntity>> call(AddNoteParams params) {
    return _repository.addNote(title: params.title, content: params.content);
  }
}
