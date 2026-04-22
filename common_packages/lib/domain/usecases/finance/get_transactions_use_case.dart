import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';
import 'package:common_packages/domain/repositories/finance_repository.dart';

class GetTransactionsParams {
  final int month;
  final int year;
  const GetTransactionsParams({required this.month, required this.year});
}

class GetTransactionsUseCase extends UseCase<List<TransactionEntity>, GetTransactionsParams> {
  final FinanceRepository _repository;
  GetTransactionsUseCase(this._repository);

  @override
  Future<Result<List<TransactionEntity>>> call(GetTransactionsParams params) {
    return _repository.getTransactions(month: params.month, year: params.year);
  }
}
