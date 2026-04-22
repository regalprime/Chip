part of 'finance_bloc.dart';

sealed class FinanceEvent extends Equatable {
  const FinanceEvent();
  @override
  List<Object?> get props => [];
}

class LoadFinanceDataEvent extends FinanceEvent {
  const LoadFinanceDataEvent();
}

class ChangeMonthEvent extends FinanceEvent {
  final int month;
  final int year;
  const ChangeMonthEvent({required this.month, required this.year});
  @override
  List<Object?> get props => [month, year];
}

class AddTransactionEvent extends FinanceEvent {
  final String categoryId;
  final TransactionType type;
  final int amount;
  final String? note;
  final DateTime date;

  const AddTransactionEvent({
    required this.categoryId,
    required this.type,
    required this.amount,
    this.note,
    required this.date,
  });
  @override
  List<Object?> get props => [categoryId, type, amount, note, date];
}

class DeleteTransactionEvent extends FinanceEvent {
  final String id;
  const DeleteTransactionEvent({required this.id});
  @override
  List<Object?> get props => [id];
}

class LoadCategoriesEvent extends FinanceEvent {
  const LoadCategoriesEvent();
}

class AddCategoryEvent extends FinanceEvent {
  final String name;
  final String icon;
  final String color;
  final TransactionType type;

  const AddCategoryEvent({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
  @override
  List<Object?> get props => [name, icon, color, type];
}

class SetBudgetEvent extends FinanceEvent {
  final String categoryId;
  final int amount;

  const SetBudgetEvent({required this.categoryId, required this.amount});
  @override
  List<Object?> get props => [categoryId, amount];
}
