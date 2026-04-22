import 'package:common_packages/core/error/exception.dart';
import 'package:common_packages/domain/entities/wish/wish_entity.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';
import 'package:common_packages/domain/repositories/wish_repository.dart';

class WishRepositoryImpl implements WishRepository {
  const WishRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RemoteDataSource _remoteDataSource;

  @override
  Future<List<WishEntity>> getWishes() async {
    try {
      return await _remoteDataSource.getWishes();
    } catch (e) {
      throw ServerException('Failed to get wishes: $e');
    }
  }

  @override
  Future<WishEntity> addWish({
    required String title,
    String? description,
    String emoji = '⭐',
  }) async {
    try {
      return await _remoteDataSource.addWish(title: title, description: description, emoji: emoji);
    } catch (e) {
      throw ServerException('Failed to add wish: $e');
    }
  }

  @override
  Future<WishEntity> updateWish({
    required String id,
    required String title,
    String? description,
    String emoji = '⭐',
  }) async {
    try {
      return await _remoteDataSource.updateWish(id: id, title: title, description: description, emoji: emoji);
    } catch (e) {
      throw ServerException('Failed to update wish: $e');
    }
  }

  @override
  Future<WishEntity> completeWish({required String id, String? completionNote}) async {
    try {
      return await _remoteDataSource.completeWish(id: id, completionNote: completionNote);
    } catch (e) {
      throw ServerException('Failed to complete wish: $e');
    }
  }

  @override
  Future<WishEntity> uncompleteWish({required String id}) async {
    try {
      return await _remoteDataSource.uncompleteWish(id: id);
    } catch (e) {
      throw ServerException('Failed to uncomplete wish: $e');
    }
  }

  @override
  Future<void> deleteWish({required String id}) async {
    try {
      await _remoteDataSource.deleteWish(id: id);
    } catch (e) {
      throw ServerException('Failed to delete wish: $e');
    }
  }
}
