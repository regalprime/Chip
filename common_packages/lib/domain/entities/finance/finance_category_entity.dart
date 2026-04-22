import 'package:equatable/equatable.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';

class FinanceCategoryEntity extends Equatable {
  final String id;
  final String? userId; // null = default category
  final String name;
  final String icon; // emoji
  final String color; // hex: "FF4CAF50"
  final TransactionType type;
  final bool isDefault;
  final DateTime createdAt;

  const FinanceCategoryEntity({
    required this.id,
    this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isDefault,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, icon, color, type, isDefault];
}
