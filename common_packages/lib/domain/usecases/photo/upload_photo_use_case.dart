import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/photo/photo_entity.dart';
import 'package:common_packages/domain/repositories/photo_repository.dart';

class UploadPhotoUseCase extends UseCase<PhotoEntity, String> {
  final PhotoRepository _repository;

  UploadPhotoUseCase(this._repository);

  @override
  Future<Result<PhotoEntity>> call(String filePath) {
    return _repository.uploadPhoto(filePath: filePath);
  }
}
