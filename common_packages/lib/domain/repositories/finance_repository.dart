import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/finance/budget_entity.dart';
import 'package:common_packages/domain/entities/finance/finance_category_entity.dart';
import 'package:common_packages/domain/entities/finance/finance_overview.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';

abstract class FinanceRepository {
  // Transactions
  Future<Result<List<TransactionEntity>>> getTransactions({
    required int month,
    required int year,
  });
  Future<Result<TransactionEntity>> addTransaction({
    required String categoryId,
    required TransactionType type,
    required int amount,
    String? note,
    required DateTime date,
  });
  Future<Result<TransactionEntity>> updateTransaction({
    required String id,
    required String categoryId,
    required TransactionType type,
    required int amount,
    String? note,
    required DateTime date,
  });
  Future<Result<void>> deleteTransaction({required String id});

  // Categories
  Future<Result<List<FinanceCategoryEntity>>> getCategories();
  Future<Result<FinanceCategoryEntity>> addCategory({
    required String name,
    required String icon,
    required String color,
    required TransactionType type,
  });

  // Budgets
  Future<Result<List<BudgetEntity>>> getBudgets({
    required int month,
    required int year,
  });
  Future<Result<BudgetEntity>> setBudget({
    required String categoryId,
    required int amount,
    required int month,
    required int year,
  });

  // Overview
  Future<Result<FinanceOverview>> getOverview({
    required int month,
    required int year,
  });
}
