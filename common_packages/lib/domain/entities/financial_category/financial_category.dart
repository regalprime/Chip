class FinancialCategory {
  final String id;
  final String name;
  final int amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FinancialCategory({
    required this.id,
    required this.name,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });
}
