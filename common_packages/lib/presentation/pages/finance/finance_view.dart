import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:common_packages/base/extensions/context_extension.dart';
import 'package:common_packages/domain/entities/finance/finance_overview.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';
import 'package:common_packages/presentation/blocs/finance/finance_bloc.dart';
import 'package:common_packages/presentation/pages/finance/add_transaction_sheet.dart';
import 'package:common_packages/presentation/pages/finance/budget_view.dart';
import 'package:common_packages/presentation/pages/finance/transaction_history_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class FinanceView extends StatefulWidget {
  const FinanceView({super.key});

  @override
  State<FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<FinanceView> {
  @override
  void initState() {
    super.initState();
    context.read<FinanceBloc>().add(const LoadFinanceDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quan ly chi tieu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<FinanceBloc>(),
                  child: const TransactionHistoryView(),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<FinanceBloc>(),
                  child: const BudgetView(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<FinanceBloc, FinanceState>(
        listener: (context, state) {
          if (state.status == FinanceStatus.error) {
            DSErrorDialog.show(context, message: state.errorMessage ?? 'Error');
          }
        },
        builder: (context, state) {
          if (state.status == FinanceStatus.loading && state.overview == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FinanceBloc>().add(const LoadFinanceDataEvent());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MonthSelector(
                  month: state.selectedMonth,
                  year: state.selectedYear,
                ),
                const SizedBox(height: 16),
                if (state.overview != null) ...[
                  _BalanceCard(overview: state.overview!),
                  const SizedBox(height: 16),
                  _IncomeExpenseRow(overview: state.overview!),
                  const SizedBox(height: 20),
                  if (state.overview!.spendingByCategory.isNotEmpty) ...[
                    _SpendingChart(spending: state.overview!.spendingByCategory),
                    const SizedBox(height: 20),
                  ],
                ],
                _RecentTransactions(transactions: state.transactions),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTransaction(context),
        icon: const Icon(Icons.add),
        label: const Text('Them'),
        backgroundColor: context.primaryColor,
        foregroundColor: context.colorScheme.onPrimary,
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<FinanceBloc>(),
        child: const AddTransactionSheet(),
      ),
    );
  }
}

// ─── Month selector ───────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  final int month;
  final int year;

  const _MonthSelector({required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    final date = DateTime(year, month);
    final label = DateFormat('MMMM yyyy').format(date);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final prev = month == 1 ? 12 : month - 1;
            final prevYear = month == 1 ? year - 1 : year;
            context.read<FinanceBloc>().add(ChangeMonthEvent(month: prev, year: prevYear));
          },
        ),
        Text(label, style: context.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            final next = month == 12 ? 1 : month + 1;
            final nextYear = month == 12 ? year + 1 : year;
            context.read<FinanceBloc>().add(ChangeMonthEvent(month: next, year: nextYear));
          },
        ),
      ],
    );
  }
}

// ─── Balance card ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final FinanceOverview overview;

  const _BalanceCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    final balance = overview.balance;
    final isPositive = balance >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primaryColor,
            context.primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'So du thang nay',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${isPositive ? '+' : ''}${_formatCurrency(balance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Income / Expense row ─────────────────────────────────────────────────────

class _IncomeExpenseRow extends StatelessWidget {
  final FinanceOverview overview;

  const _IncomeExpenseRow({required this.overview});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.arrow_downward_rounded,
            iconColor: context.appColors.success,
            label: 'Thu nhap',
            amount: overview.totalIncome,
            amountColor: context.appColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.arrow_upward_rounded,
            iconColor: Colors.redAccent,
            label: 'Chi tieu',
            amount: overview.totalExpense,
            amountColor: Colors.redAccent,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final int amount;
  final Color amountColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: context.appColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  _formatCurrency(amount),
                  style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Spending pie chart ───────────────────────────────────────────────────────

class _SpendingChart extends StatelessWidget {
  final List<CategorySpending> spending;

  const _SpendingChart({required this.spending});

  @override
  Widget build(BuildContext context) {
    final total = spending.fold<int>(0, (sum, s) => sum + s.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tieu theo danh muc',
          style: context.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: spending.map((s) {
                      final percent = total > 0 ? (s.amount / total * 100) : 0;
                      return PieChartSectionData(
                        value: s.amount.toDouble(),
                        color: Color(int.parse('0x${s.categoryColor}')),
                        radius: 50,
                        title: '${percent.toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: spending.take(5).map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(int.parse('0x${s.categoryColor}')),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(s.categoryIcon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              s.categoryName,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Recent transactions ──────────────────────────────────────────────────────

class _RecentTransactions extends StatelessWidget {
  final List<TransactionEntity> transactions;

  const _RecentTransactions({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final recent = transactions.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Giao dich gan day',
                style: context.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (transactions.length > 10)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<FinanceBloc>(),
                      child: const TransactionHistoryView(),
                    ),
                  ),
                ),
                child: const Text('Xem tat ca'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 48, color: context.appColors.textSecondary),
                  const SizedBox(height: 8),
                  Text('Chua co giao dich', style: TextStyle(color: context.appColors.textSecondary)),
                ],
              ),
            ),
          )
        else
          ...recent.map((t) => TransactionTile(transaction: t)),
      ],
    );
  }
}

// ─── Transaction tile (shared) ────────────────────────────────────────────────

class TransactionTile extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? context.appColors.success : Colors.redAccent;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<FinanceBloc>().add(DeleteTransactionEvent(id: transaction.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.appColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.appColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: transaction.categoryColor != null
                    ? Color(int.parse('0x${transaction.categoryColor}')).withOpacity(0.15)
                    : context.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(transaction.categoryIcon ?? '📦', style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.categoryName ?? 'Unknown',
                    style: context.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty)
                    Text(
                      transaction.note!,
                      style: TextStyle(color: context.appColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${_formatCurrency(transaction.amount)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  DateFormat('dd/MM').format(transaction.date),
                  style: TextStyle(color: context.appColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Utils ────────────────────────────────────────────────────────────────────

String _formatCurrency(int amount) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(amount)}d';
}
