import 'package:common_packages/base/extensions/context_extension.dart';
import 'package:common_packages/domain/entities/finance/finance_category_entity.dart';
import 'package:common_packages/domain/entities/finance/transaction_entity.dart';
import 'package:common_packages/presentation/blocs/finance/finance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  FinanceCategoryEntity? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode ? context.surfaceColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocListener<FinanceBloc, FinanceState>(
        listener: (context, state) {
          if (state.status == FinanceStatus.loaded) {
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20, 12, 20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: context.appColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text('Them giao dich', style: context.headlineLarge),
                const SizedBox(height: 20),

                // Type toggle
                _TypeToggle(
                  type: _type,
                  onChanged: (t) => setState(() {
                    _type = t;
                    _selectedCategory = null;
                  }),
                ),
                const SizedBox(height: 16),

                // Amount
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: 'VND',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Category picker
                Text('Danh muc', style: context.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                BlocBuilder<FinanceBloc, FinanceState>(
                  builder: (context, state) {
                    final cats = state.categories.where((c) => c.type == _type).toList();
                    return _CategoryGrid(
                      categories: cats,
                      selectedId: _selectedCategory?.id,
                      onSelected: (cat) => setState(() => _selectedCategory = cat),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Date
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.appColors.divider),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 12),
                        Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Note
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  maxLength: 100,
                  decoration: InputDecoration(
                    hintText: 'Ghi chu (tuy chon)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Submit
                BlocBuilder<FinanceBloc, FinanceState>(
                  builder: (context, state) {
                    final isSaving = state.status == FinanceStatus.saving;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: isSaving ? null : _submit,
                        child: isSaving
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(
                                _type == TransactionType.income ? 'Them thu nhap' : 'Them chi tieu',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _submit() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhap so tien')));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chon danh muc')));
      return;
    }

    final amount = int.tryParse(amountText) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('So tien phai lon hon 0')));
      return;
    }

    context.read<FinanceBloc>().add(AddTransactionEvent(
      categoryId: _selectedCategory!.id,
      type: _type,
      amount: amount,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      date: _selectedDate,
    ));
  }
}

// ─── Type toggle ──────────────────────────────────────────────────────────────

class _TypeToggle extends StatelessWidget {
  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  const _TypeToggle({required this.type, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ToggleItem(
            label: 'Chi tieu',
            icon: Icons.arrow_upward,
            isSelected: type == TransactionType.expense,
            color: Colors.redAccent,
            onTap: () => onChanged(TransactionType.expense),
          ),
          _ToggleItem(
            label: 'Thu nhap',
            icon: Icons.arrow_downward,
            isSelected: type == TransactionType.income,
            color: context.appColors.success,
            onTap: () => onChanged(TransactionType.income),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: color) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? color : context.appColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : context.appColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category grid ────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final List<FinanceCategoryEntity> categories;
  final String? selectedId;
  final ValueChanged<FinanceCategoryEntity> onSelected;

  const _CategoryGrid({
    required this.categories,
    this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Chua co danh muc', style: TextStyle(color: context.appColors.textSecondary)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = cat.id == selectedId;
        final color = Color(int.parse('0x${cat.color}'));

        return GestureDetector(
          onTap: () => onSelected(cat),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.15) : context.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : context.appColors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? color : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
