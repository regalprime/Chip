import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final TransactionType type;
  final int amount; // VND — luôn dương, type quyết định cộng/trừ
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Denormalized from join
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  });

  @override
  List<Object?> get props => [id, userId, categoryId, type, amount, note, date];
}
