import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/core/use_case/base_use_case.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';
import 'package:common_packages/domain/repositories/finance_repository.dart';

class AddTransactionParams {
  final String categoryId;
  final TransactionType type;
  final int amount;
  final String? note;
  final DateTime date;

  const AddTransactionParams({
    required this.categoryId,
    required this.type,
    required this.amount,
    this.note,
    required this.date,
  });
}

class AddTransactionUseCase extends UseCase<TransactionEntity, AddTransactionParams> {
  final FinanceRepository _repository;
  AddTransactionUseCase(this._repository);

  @override
  Future<Result<TransactionEntity>> call(AddTransactionParams params) {
    return _repository.addTransaction(
      categoryId: params.categoryId,
      type: params.type,
      amount: params.amount,
      note: params.note,
      date: params.date,
    );
  }
}
