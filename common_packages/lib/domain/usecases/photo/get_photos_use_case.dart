import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/photo/photo_entity.dart';
import 'package:common_packages/domain/repositories/photo_repository.dart';

class GetPhotosUseCase extends UseCaseNoParams<List<PhotoEntity>> {
  final PhotoRepository _repository;

  GetPhotosUseCase(this._repository);

  @override
  Future<Result<List<PhotoEntity>>> call() {
    return _repository.getPhotos();
  }
}
