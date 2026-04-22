import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/finance/finance_category_entity.dart';
import 'package:common_packages/domain/repositories/finance_repository.dart';

class GetFinanceCategoriesUseCase extends UseCaseNoParams<List<FinanceCategoryEntity>> {
  final FinanceRepository _repository;
  GetFinanceCategoriesUseCase(this._repository);

  @override
  Future<Result<List<FinanceCategoryEntity>>> call() {
    return _repository.getCategories();
  }
}
