import 'package:common_packages/domain/entities/finance/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.userId,
    required super.categoryId,
    required super.amount,
    required super.month,
    required super.year,
    required super.createdAt,
    super.categoryName,
    super.categoryIcon,
    super.categoryColor,
    super.spent,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;

    return BudgetModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      amount: json['amount'] as int,
      month: json['month'] as int,
      year: json['year'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      categoryName: category?['name'] as String?,
      categoryIcon: category?['icon'] as String?,
      categoryColor: category?['color'] as String?,
    );
  }
}
