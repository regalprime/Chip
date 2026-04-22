import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/repositories/photo_repository.dart';

class DeletePhotosUseCase extends UseCase<void, List<String>> {
  final PhotoRepository _repository;

  DeletePhotosUseCase(this._repository);

  @override
  Future<Result<void>> call(List<String> photoIds) {
    return _repository.deletePhotos(photoIds: photoIds);
  }
}
