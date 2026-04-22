import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:common_packages/base/extensions/context_extension.dart';
import 'package:common_packages/domain/entities/day_counter/day_counter_entity.dart';
import 'package:common_packages/presentation/pages/counter_day/day_counter_form_sheet.dart';
import 'package:common_packages/presentation/pages/counter_day/day_counter_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/counter_day/day_counter_bloc.dart';

class DayCounterView extends StatelessWidget {
  const DayCounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.titleDayCounter)),
      body: BlocConsumer<DayCounterBloc, DayCounterState>(
        listener: (context, state) {
          if (state.status == DayCounterStatus.error && state.errorMessage != null) {
            DSErrorDialog.show(context, message: state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == DayCounterStatus.loading && state.counters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.counters.isEmpty) {
            return _EmptyCounterState(
              onAdd: () => _showAddSheet(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DayCounterBloc>().add(const LoadDayCountersEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: state.counters.length,
              itemBuilder: (context, index) {
                final counter = state.counters[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _DayCounterCard(counter: counter),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<DayCounterBloc>(),
        child: const DayCounterFormSheet(),
      ),
    );
  }
}

// ─── Empty State ────────────────────────────────────────────────────────────

class _EmptyCounterState extends StatelessWidget {
  const _EmptyCounterState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '❤️',
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chua co ngay nao',
              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Them ngay dac biet de bat dau dem',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Them ngay moi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Counter Card ───────────────────────────────────────────────────────────

class _DayCounterCard extends StatelessWidget {
  const _DayCounterCard({required this.counter});

  final DayCounterEntity counter;

  Color _parseColor() {
    try {
      return Color(int.parse(counter.colorHex, radix: 16));
    } catch (_) {
      return const Color(0xFFD32F2F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _parseColor();
    final daysDiff = counter.daysDiff;
    final isCountingUp = counter.isCountingUp;
    final absDays = daysDiff.abs();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<DayCounterBloc>(),
              child: DayCounterDetailView(counter: counter),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.75),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: emoji + title
              Row(
                children: [
                  Text(counter.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      counter.title,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Big day count
              Center(
                child: Column(
                  children: [
                    Text(
                      absDays.toString(),
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCountingUp ? 'ngay da qua' : 'ngay nua',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Date info row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DateInfoChip(
                    label: isCountingUp ? 'Bat dau' : 'Muc tieu',
                    date: counter.targetDate,
                  ),
                  _TimeBreakdown(absDays: absDays),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateInfoChip extends StatelessWidget {
  const _DateInfoChip({required this.label, required this.date});

  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TimeBreakdown extends StatelessWidget {
  const _TimeBreakdown({required this.absDays});

  final int absDays;

  @override
  Widget build(BuildContext context) {
    final years = absDays ~/ 365;
    final months = (absDays % 365) ~/ 30;
    final days = absDays % 30;

    String text;
    if (years > 0) {
      text = '${years}y ${months}m ${days}d';
    } else if (months > 0) {
      text = '${months}m ${days}d';
    } else {
      text = '${days}d';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
