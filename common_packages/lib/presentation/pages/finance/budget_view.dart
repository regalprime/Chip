import 'package:common_packages/base/extensions/context_extension.dart';
import 'package:common_packages/domain/entities/finance/budget_entity.dart';
import 'package:common_packages/domain/entities/finance/finance_category_entity.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';
import 'package:common_packages/presentation/blocs/finance/finance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class BudgetView extends StatelessWidget {
  const BudgetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ngan sach')),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          final month = DateFormat('MM/yyyy').format(DateTime(state.selectedYear, state.selectedMonth));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Ngan sach thang $month', style: context.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),

              if (state.budgets.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 48, color: context.appColors.textSecondary),
                        const SizedBox(height: 8),
                        Text('Chua dat ngan sach', style: TextStyle(color: context.appColors.textSecondary)),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _showAddBudgetDialog(context, state),
                          icon: const Icon(Icons.add),
                          label: const Text('Dat ngan sach'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                ...state.budgets.map((b) => _BudgetCard(budget: b)),
                const SizedBox(height: 16),
                Center(
                  child: FilledButton.icon(
                    onPressed: () => _showAddBudgetDialog(context, state),
                    icon: const Icon(Icons.add),
                    label: const Text('Them ngan sach'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, FinanceState state) {
    final expenseCategories = state.categories.where((c) => c.type == TransactionType.expense).toList();
    final existingCatIds = state.budgets.map((b) => b.categoryId).toSet();
    final available = expenseCategories.where((c) => !existingCatIds.contains(c.id)).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tat ca danh muc da co ngan sach')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<FinanceBloc>(),
        child: _AddBudgetDialog(categories: available),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetEntity budget;

  const _BudgetCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final progress = budget.progress.clamp(0.0, 1.0);
    final isOver = budget.isOverBudget;
    final color = isOver
        ? Colors.redAccent
        : progress > 0.8
            ? Colors.orange
            : context.appColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOver ? Colors.redAccent.withOpacity(0.5) : context.appColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(budget.categoryIcon ?? '📦', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  budget.categoryName ?? 'Unknown',
                  style: context.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${NumberFormat('#,###').format(budget.spent ?? 0)} / ${NumberFormat('#,###').format(budget.amount)}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                  ),
                  if (isOver)
                    Text(
                      'Vuot ${NumberFormat('#,###').format((budget.spent ?? 0) - budget.amount)}d',
                      style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.surfaceColor,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddBudgetDialog extends StatefulWidget {
  final List<FinanceCategoryEntity> categories;

  const _AddBudgetDialog({required this.categories});

  @override
  State<_AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<_AddBudgetDialog> {
  final _amountController = TextEditingController();
  FinanceCategoryEntity? _selected;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dat ngan sach'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<FinanceCategoryEntity>(
            value: _selected,
            decoration: const InputDecoration(labelText: 'Danh muc'),
            items: widget.categories.map((c) {
              return DropdownMenuItem(value: c, child: Text('${c.icon} ${c.name}'));
            }).toList(),
            onChanged: (v) => setState(() => _selected = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Han muc (VND)',
              hintText: '1000000',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huy')),
        FilledButton(
          onPressed: () {
            if (_selected == null || _amountController.text.isEmpty) return;
            final amount = int.tryParse(_amountController.text) ?? 0;
            if (amount <= 0) return;

            context.read<FinanceBloc>().add(SetBudgetEvent(
              categoryId: _selected!.id,
              amount: amount,
            ));
            Navigator.pop(context);
          },
          child: const Text('Luu'),
        ),
      ],
    );
  }
}
