import 'package:equatable/equatable.dart';

class CategorySpending extends Equatable {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final int amount;

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.amount,
  });

  @override
  List<Object?> get props => [categoryId, amount];
}

class FinanceOverview extends Equatable {
  final int totalIncome;
  final int totalExpense;
  final List<CategorySpending> spendingByCategory;
  final int month;
  final int year;

  const FinanceOverview({
    required this.totalIncome,
    required this.totalExpense,
    required this.spendingByCategory,
    required this.month,
    required this.year,
  });

  int get balance => totalIncome - totalExpense;

  @override
  List<Object?> get props => [totalIncome, totalExpense, month, year];
}
