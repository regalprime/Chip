import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/repositories/finance_repository.dart';

class DeleteTransactionUseCase extends UseCase<void, String> {
  final FinanceRepository _repository;
  DeleteTransactionUseCase(this._repository);

  @override
  Future<Result<void>> call(String id) {
    return _repository.deleteTransaction(id: id);
  }
}
