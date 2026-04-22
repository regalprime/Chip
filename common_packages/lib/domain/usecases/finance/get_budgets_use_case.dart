import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/finance/budget_entity.dart';
import 'package:common_packages/domain/repositories/finance_repository.dart';

class GetBudgetsParams {
  final int month;
  final int year;
  const GetBudgetsParams({required this.month, required this.year});
}

class GetBudgetsUseCase extends UseCase<List<BudgetEntity>, GetBudgetsParams> {
  final FinanceRepository _repository;
  GetBudgetsUseCase(this._repository);

  @override
  Future<Result<List<BudgetEntity>>> call(GetBudgetsParams params) {
    return _repository.getBudgets(month: params.month, year: params.year);
  }
}
