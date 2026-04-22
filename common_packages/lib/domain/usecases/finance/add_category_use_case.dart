import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/finance/finance_category_entity.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';
import 'package:common_packages/domain/repositories/finance_repository.dart';

class AddCategoryParams {
  final String name;
  final String icon;
  final String color;
  final TransactionType type;

  const AddCategoryParams({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class AddFinanceCategoryUseCase extends UseCase<FinanceCategoryEntity, AddCategoryParams> {
  final FinanceRepository _repository;
  AddFinanceCategoryUseCase(this._repository);

  @override
  Future<Result<FinanceCategoryEntity>> call(AddCategoryParams params) {
    return _repository.addCategory(
      name: params.name,
      icon: params.icon,
      color: params.color,
      type: params.type,
    );
  }
}
