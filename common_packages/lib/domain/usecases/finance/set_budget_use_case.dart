import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/finance/budget_entity.dart';
import 'package:common_packages/domain/repositories/finance_repository.dart';

class SetBudgetParams {
  final String categoryId;
  final int amount;
  final int month;
  final int year;

  const SetBudgetParams({
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
  });
}

class SetBudgetUseCase extends UseCase<BudgetEntity, SetBudgetParams> {
  final FinanceRepository _repository;
  SetBudgetUseCase(this._repository);

  @override
  Future<Result<BudgetEntity>> call(SetBudgetParams params) {
    return _repository.setBudget(
      categoryId: params.categoryId,
      amount: params.amount,
      month: params.month,
      year: params.year,
    );
  }
}
