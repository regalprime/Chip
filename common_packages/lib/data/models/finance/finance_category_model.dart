import 'package:common_packages/domain/entities/finance/finance_category_entity.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';

class FinanceCategoryModel extends FinanceCategoryEntity {
  const FinanceCategoryModel({
    required super.id,
    super.userId,
    required super.name,
    required super.icon,
    required super.color,
    required super.type,
    required super.isDefault,
    required super.createdAt,
  });

  factory FinanceCategoryModel.fromJson(Map<String, dynamic> json) {
    return FinanceCategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
