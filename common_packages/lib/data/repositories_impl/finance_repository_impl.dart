import 'package:common_packages/core/error/app_failure.dart';
import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/finance/budget_entity.dart';
import 'package:common_packages/domain/entities/finance/finance_category_entity.dart';
import 'package:common_packages/domain/entities/finance/finance_overview.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';
import 'package:common_packages/domain/repositories/finance_repository.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  const FinanceRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<TransactionEntity>>> getTransactions({
    required int month,
    required int year,
  }) async {
    try {
      final data = await _remoteDataSource.getTransactions(month: month, year: year);
      return Success(data);
    } catch (e) {
      return Failure(ServerFailure('Failed to get transactions: $e'));
    }
  }

  @override
  Future<Result<TransactionEntity>> addTransaction({
    required String categoryId,
    required TransactionType type,
    required int amount,
    String? note,
    required DateTime date,
  }) async {
    try {
      final data = await _remoteDataSource.addTransaction(
        categoryId: categoryId, type: type, amount: amount, note: note, date: date,
      );
      return Success(data);
    } catch (e) {
      return Failure(ServerFailure('Failed to add transaction: $e'));
    }
  }

  @override
  Future<Result<TransactionEntity>> updateTransaction({
    required String id,
    required String categoryId,
    required TransactionType type,
    required int amount,
    String? note,
    required DateTime date,
  }) async {
    try {
      final data = await _remoteDataSource.updateTransaction(
        id: id, categoryId: categoryId, type: type, amount: amount, note: note, date: date,
      );
      return Success(data);
    } catch (e) {
      return Failure(ServerFailure('Failed to update transaction: $e'));
    }
  }

  @override
  Future<Result<void>> deleteTransaction({required String id}) async {
    try {
      await _remoteDataSource.deleteTransaction(id: id);
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to delete transaction: $e'));
    }
  }

  @override
  Future<Result<List<FinanceCategoryEntity>>> getCategories() async {
    try {
      final data = await _remoteDataSource.getFinanceCategories();
      return Success(data);
    } catch (e) {
      return Failure(ServerFailure('Failed to get categories: $e'));
    }
  }

  @override
  Future<Result<FinanceCategoryEntity>> addCategory({
    required String name,
    required String icon,
    required String color,
    required TransactionType type,
  }) async {
    try {
      final data = await _remoteDataSource.addFinanceCategory(
        name: name, icon: icon, color: color, type: type,
      );
      return Success(data);
    } catch (e) {
      return Failure(ServerFailure('Failed to add category: $e'));
    }
  }

  @override
  Future<Result<List<BudgetEntity>>> getBudgets({
    required int month,
    required int year,
  }) async {
    try {
      final data = await _remoteDataSource.getBudgets(month: month, year: year);
      return Success(data);
    } catch (e) {
      return Failure(ServerFailure('Failed to get budgets: $e'));
    }
  }

  @override
  Future<Result<BudgetEntity>> setBudget({
    required String categoryId,
    required int amount,
    required int month,
    required int year,
  }) async {
    try {
      final data = await _remoteDataSource.setBudget(
        categoryId: categoryId, amount: amount, month: month, year: year,
      );
      return Success(data);
    } catch (e) {
      return Failure(ServerFailure('Failed to set budget: $e'));
    }
  }

  @override
  Future<Result<FinanceOverview>> getOverview({
    required int month,
    required int year,
  }) async {
    try {
      final data = await _remoteDataSource.getFinanceOverview(month: month, year: year);
      return Success(data);
    } catch (e) {
      return Failure(ServerFailure('Failed to get overview: $e'));
    }
  }
}
