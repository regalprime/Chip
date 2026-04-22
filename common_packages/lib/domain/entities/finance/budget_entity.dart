import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final int amount; // Budget limit (VND)
  final int month; // 1-12
  final int year;
  final DateTime createdAt;
  // Denormalized
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  // Computed — tổng chi tiêu thực tế trong tháng
  final int? spent;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
    required this.createdAt,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.spent,
  });

  double get progress => spent != null && amount > 0 ? spent! / amount : 0;
  bool get isOverBudget => spent != null && spent! > amount;

  @override
  List<Object?> get props => [id, userId, categoryId, amount, month, year];
}
