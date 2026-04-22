import 'package:common_packages/domain/entities/finance/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.categoryId,
    required super.type,
    required super.amount,
    super.note,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
    super.categoryName,
    super.categoryIcon,
    super.categoryColor,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;

    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      amount: json['amount'] as int,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      categoryName: category?['name'] as String?,
      categoryIcon: category?['icon'] as String?,
      categoryColor: category?['color'] as String?,
    );
  }
}
