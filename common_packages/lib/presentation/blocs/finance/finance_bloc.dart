import 'package:common_packages/core/result/result.dart';
import 'package:common_packages/domain/entities/finance/budget_entity.dart';
import 'package:common_packages/domain/entities/finance/finance_category_entity.dart';
import 'package:common_packages/domain/entities/finance/finance_overview.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';
import 'package:common_packages/domain/usecases/finance/add_category_use_case.dart';
import 'package:common_packages/domain/usecases/finance/add_transaction_use_case.dart';
import 'package:common_packages/domain/usecases/finance/delete_transaction_use_case.dart';
import 'package:common_packages/domain/usecases/finance/get_budgets_use_case.dart';
import 'package:common_packages/domain/usecases/finance/get_categories_use_case.dart';
import 'package:common_packages/domain/usecases/finance/get_overview_use_case.dart';
import 'package:common_packages/domain/usecases/finance/get_transactions_use_case.dart';
import 'package:common_packages/domain/usecases/finance/set_budget_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'finance_event.dart';
part 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  FinanceBloc({
    required GetTransactionsUseCase getTransactionsUseCase,
    required AddTransactionUseCase addTransactionUseCase,
    required DeleteTransactionUseCase deleteTransactionUseCase,
    required GetFinanceCategoriesUseCase getCategoriesUseCase,
    required AddFinanceCategoryUseCase addCategoryUseCase,
    required GetFinanceOverviewUseCase getOverviewUseCase,
    required GetBudgetsUseCase getBudgetsUseCase,
    required SetBudgetUseCase setBudgetUseCase,
  })  : _getTransactionsUseCase = getTransactionsUseCase,
        _addTransactionUseCase = addTransactionUseCase,
        _deleteTransactionUseCase = deleteTransactionUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        _addCategoryUseCase = addCategoryUseCase,
        _getOverviewUseCase = getOverviewUseCase,
        _getBudgetsUseCase = getBudgetsUseCase,
        _setBudgetUseCase = setBudgetUseCase,
        super(FinanceState(
          selectedMonth: DateTime.now().month,
          selectedYear: DateTime.now().year,
        )) {
    on<LoadFinanceDataEvent>(_onLoadData);
    on<ChangeMonthEvent>(_onChangeMonth);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<SetBudgetEvent>(_onSetBudget);
  }

  final GetTransactionsUseCase _getTransactionsUseCase;
  final AddTransactionUseCase _addTransactionUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;
  final GetFinanceCategoriesUseCase _getCategoriesUseCase;
  final AddFinanceCategoryUseCase _addCategoryUseCase;
  final GetFinanceOverviewUseCase _getOverviewUseCase;
  final GetBudgetsUseCase _getBudgetsUseCase;
  final SetBudgetUseCase _setBudgetUseCase;

  Future<void> _onLoadData(LoadFinanceDataEvent event, Emitter<FinanceState> emit) async {
    emit(state.copyWith(status: FinanceStatus.loading));

    final month = state.selectedMonth;
    final year = state.selectedYear;

    // Load all data in parallel
    final results = await Future.wait([
      _getOverviewUseCase(GetOverviewParams(month: month, year: year)),
      _getTransactionsUseCase(GetTransactionsParams(month: month, year: year)),
      _getCategoriesUseCase(),
      _getBudgetsUseCase(GetBudgetsParams(month: month, year: year)),
    ]);

    final overviewResult = results[0] as Result<FinanceOverview>;
    final transactionsResult = results[1] as Result<List<TransactionEntity>>;
    final categoriesResult = results[2] as Result<List<FinanceCategoryEntity>>;
    final budgetsResult = results[3] as Result<List<BudgetEntity>>;

    if (overviewResult.isFailure) {
      emit(state.copyWith(status: FinanceStatus.error, errorMessage: overviewResult.failureOrNull?.message));
      return;
    }

    emit(state.copyWith(
      status: FinanceStatus.loaded,
      overview: overviewResult.dataOrNull,
      transactions: transactionsResult.dataOrNull ?? [],
      categories: categoriesResult.dataOrNull ?? [],
      budgets: budgetsResult.dataOrNull ?? [],
    ));
  }

  Future<void> _onChangeMonth(ChangeMonthEvent event, Emitter<FinanceState> emit) async {
    emit(state.copyWith(selectedMonth: event.month, selectedYear: event.year));
    add(const LoadFinanceDataEvent());
  }

  Future<void> _onAddTransaction(AddTransactionEvent event, Emitter<FinanceState> emit) async {
    emit(state.copyWith(status: FinanceStatus.saving));

    final result = await _addTransactionUseCase(AddTransactionParams(
      categoryId: event.categoryId,
      type: event.type,
      amount: event.amount,
      note: event.note,
      date: event.date,
    ));

    result.when(
      success: (_) => add(const LoadFinanceDataEvent()),
      failure: (f) => emit(state.copyWith(status: FinanceStatus.error, errorMessage: f.message)),
    );
  }

  Future<void> _onDeleteTransaction(DeleteTransactionEvent event, Emitter<FinanceState> emit) async {
    final result = await _deleteTransactionUseCase(event.id);

    result.when(
      success: (_) => add(const LoadFinanceDataEvent()),
      failure: (f) => emit(state.copyWith(status: FinanceStatus.error, errorMessage: f.message)),
    );
  }

  Future<void> _onLoadCategories(LoadCategoriesEvent event, Emitter<FinanceState> emit) async {
    final result = await _getCategoriesUseCase();
    result.when(
      success: (categories) => emit(state.copyWith(categories: categories)),
      failure: (f) => emit(state.copyWith(status: FinanceStatus.error, errorMessage: f.message)),
    );
  }

  Future<void> _onAddCategory(AddCategoryEvent event, Emitter<FinanceState> emit) async {
    final result = await _addCategoryUseCase(AddCategoryParams(
      name: event.name,
      icon: event.icon,
      color: event.color,
      type: event.type,
    ));

    result.when(
      success: (category) {
        final updated = [...state.categories, category];
        emit(state.copyWith(categories: updated));
      },
      failure: (f) => emit(state.copyWith(status: FinanceStatus.error, errorMessage: f.message)),
    );
  }

  Future<void> _onSetBudget(SetBudgetEvent event, Emitter<FinanceState> emit) async {
    final result = await _setBudgetUseCase(SetBudgetParams(
      categoryId: event.categoryId,
      amount: event.amount,
      month: state.selectedMonth,
      year: state.selectedYear,
    ));

    result.when(
      success: (_) => add(const LoadFinanceDataEvent()),
      failure: (f) => emit(state.copyWith(status: FinanceStatus.error, errorMessage: f.message)),
    );
  }
}
