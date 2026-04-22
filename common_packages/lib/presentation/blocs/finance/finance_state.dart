part of 'finance_bloc.dart';

enum FinanceStatus { initial, loading, loaded, saving, error }

class FinanceState extends Equatable {
  final FinanceStatus status;
  final int selectedMonth;
  final int selectedYear;
  final FinanceOverview? overview;
  final List<TransactionEntity> transactions;
  final List<FinanceCategoryEntity> categories;
  final List<BudgetEntity> budgets;
  final String? errorMessage;

  const FinanceState({
    this.status = FinanceStatus.initial,
    required this.selectedMonth,
    required this.selectedYear,
    this.overview,
    this.transactions = const [],
    this.categories = const [],
    this.budgets = const [],
    this.errorMessage,
  });

  FinanceState copyWith({
    FinanceStatus? status,
    int? selectedMonth,
    int? selectedYear,
    FinanceOverview? overview,
    List<TransactionEntity>? transactions,
    List<FinanceCategoryEntity>? categories,
    List<BudgetEntity>? budgets,
    String? errorMessage,
  }) {
    return FinanceState(
      status: status ?? this.status,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      overview: overview ?? this.overview,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      budgets: budgets ?? this.budgets,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedMonth, selectedYear, overview, transactions, categories, budgets, errorMessage];
}
