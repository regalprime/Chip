import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/finance/finance_overview.dart';
import 'package:common_packages/domain/repositories/finance_repository.dart';

class GetOverviewParams {
  final int month;
  final int year;
  const GetOverviewParams({required this.month, required this.year});
}

class GetFinanceOverviewUseCase extends UseCase<FinanceOverview, GetOverviewParams> {
  final FinanceRepository _repository;
  GetFinanceOverviewUseCase(this._repository);

  @override
  Future<Result<FinanceOverview>> call(GetOverviewParams params) {
    return _repository.getOverview(month: params.month, year: params.year);
  }
}
