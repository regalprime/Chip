import 'package:common_packages/core/error/app_failure.dart';
import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/photo/photo_entity.dart';
import 'package:common_packages/domain/repositories/photo_repository.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  const PhotoRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RemoteDataSource _remoteDataSource;

  @override
  Future<Result<PhotoEntity>> uploadPhoto({required String filePath}) async {
    try {
      final photo = await _remoteDataSource.uploadPhoto(filePath: filePath);
      return Success(photo);
    } catch (e) {
      return Failure(ServerFailure('Failed to upload photo: $e'));
    }
  }

  @override
  Future<Result<List<PhotoEntity>>> getPhotos() async {
    try {
      final photos = await _remoteDataSource.getPhotos();
      return Success(photos);
    } catch (e) {
      return Failure(ServerFailure('Failed to get photos: $e'));
    }
  }

  @override
  Future<Result<void>> deletePhotos({required List<String> photoIds}) async {
    try {
      await _remoteDataSource.deletePhotos(photoIds: photoIds);
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to delete photos: $e'));
    }
  }
}
