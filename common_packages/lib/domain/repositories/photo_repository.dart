import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/photo/photo_entity.dart';

abstract class PhotoRepository {
  Future<Result<PhotoEntity>> uploadPhoto({required String filePath});
  Future<Result<List<PhotoEntity>>> getPhotos();
  Future<Result<void>> deletePhotos({required List<String> photoIds});
}
