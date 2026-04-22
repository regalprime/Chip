import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/domain/repositories/friend_repository.dart';

class SearchUsersUseCase extends UseCase<List<UserEntity>, String> {
  final FriendRepository _repository;

  SearchUsersUseCase(this._repository);

  @override
  Future<Result<List<UserEntity>>> call(String query) {
    return _repository.searchUsers(query: query);
  }
}
