import 'package:common_packages/domain/entities/wish/wish_entity.dart';

abstract class WishRepository {
  Future<List<WishEntity>> getWishes();
  Future<WishEntity> addWish({required String title, String? description, String emoji});
  Future<WishEntity> updateWish({required String id, required String title, String? description, String emoji});
  Future<WishEntity> completeWish({required String id, String? completionNote});
  Future<WishEntity> uncompleteWish({required String id});
  Future<void> deleteWish({required String id});
}
