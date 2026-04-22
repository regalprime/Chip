import 'package:common_packages/base/extensions/context_extension.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';
import 'package:common_packages/presentation/blocs/finance/finance_bloc.dart';
import 'package:common_packages/presentation/pages/finance/finance_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransactionHistoryView extends StatelessWidget {
  const TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lich su giao dich')),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          if (state.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: context.appColors.textSecondary),
                  const SizedBox(height: 12),
                  Text('Chua co giao dich', style: TextStyle(color: context.appColors.textSecondary)),
                ],
              ),
            );
          }

          // Group by date
          final grouped = <String, List<TransactionEntity>>{};
          for (final t in state.transactions) {
            final key = DateFormat('dd/MM/yyyy').format(t.date);
            grouped.putIfAbsent(key, () => []).add(t);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final dateKey = grouped.keys.elementAt(index);
              final items = grouped[dateKey]!;

              final dayIncome = items
                  .where((t) => t.type == TransactionType.income)
                  .fold<int>(0, (s, t) => s + t.amount);
              final dayExpense = items
                  .where((t) => t.type == TransactionType.expense)
                  .fold<int>(0, (s, t) => s + t.amount);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          dateKey,
                          style: context.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        if (dayIncome > 0)
                          Text(
                            '+${NumberFormat('#,###').format(dayIncome)}',
                            style: TextStyle(color: context.appColors.success, fontSize: 12),
                          ),
                        if (dayIncome > 0 && dayExpense > 0)
                          const SizedBox(width: 8),
                        if (dayExpense > 0)
                          Text(
                            '-${NumberFormat('#,###').format(dayExpense)}',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  ...items.map((t) => TransactionTile(transaction: t)),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
