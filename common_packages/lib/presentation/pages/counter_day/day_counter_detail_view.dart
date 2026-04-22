import 'package:common_packages/base/extensions/context_extension.dart';
import 'package:common_packages/domain/entities/day_counter/day_counter_entity.dart';
import 'package:common_packages/domain/entities/day_counter/day_milestone.dart';
import 'package:common_packages/presentation/pages/counter_day/day_counter_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/counter_day/day_counter_bloc.dart';

class DayCounterDetailView extends StatelessWidget {
  const DayCounterDetailView({super.key, required this.counter});

  final DayCounterEntity counter;

  static const _milestoneTargets = [
    7, 30, 50, 100, 200, 365, 500, 730, 1000, 1095, 1500, 2000, 2555, 3650,
  ];

  List<DayMilestone> _buildMilestones(int daysDiff) {
    return _milestoneTargets.map((target) {
      final remaining = target - daysDiff;
      return DayMilestone(
        targetDays: target,
        daysRemaining: remaining > 0 ? remaining : 0,
      );
    }).toList();
  }

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
    final absDays = daysDiff.abs();
    final isCountingUp = counter.isCountingUp;
    final milestones = _buildMilestones(absDays);

    return BlocListener<DayCounterBloc, DayCounterState>(
      listener: (context, state) {
        // Pop if this counter was deleted
        if (!state.counters.any((c) => c.id == counter.id)) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // ── Hero header ──
            SliverAppBar(
              expandedHeight: 340,
              pinned: true,
              backgroundColor: color,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditSheet(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [color, color.withOpacity(0.8)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Emoji
                          Text(counter.emoji, style: const TextStyle(fontSize: 56)),
                          const SizedBox(height: 12),

                          // Title
                          Text(
                            counter.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Big day count
                          Text(
                            absDays.toString(),
                            style: const TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isCountingUp ? 'ngay da qua' : 'ngay nua',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Content ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time breakdown card
                    _TimeBreakdownCard(
                      absDays: absDays,
                      isCountingUp: isCountingUp,
                      targetDate: counter.targetDate,
                      color: color,
                    ),
                    const SizedBox(height: 24),

                    // Note
                    if (counter.note != null && counter.note!.isNotEmpty) ...[
                      _SectionCard(
                        icon: Icons.note_outlined,
                        title: 'Ghi chu',
                        child: Text(
                          counter.note!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Milestones
                    Text(
                      'Cot moc',
                      style: theme.textTheme.headlineLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ...milestones.map((m) => _MilestoneRow(
                          milestone: m,
                          color: color,
                          currentDays: absDays,
                        )),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    // Find the latest version from BLoC state
    final state = context.read<DayCounterBloc>().state;
    final latestCounter = state.counters.firstWhere(
      (c) => c.id == counter.id,
      orElse: () => counter,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<DayCounterBloc>(),
        child: DayCounterFormSheet(counter: latestCounter),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoa bo dem?'),
        content: Text('Ban co chac muon xoa "${counter.title}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<DayCounterBloc>().add(
                    DeleteDayCounterEvent(id: counter.id),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
  }
}

// ─── Time Breakdown Card ────────────────────────────────────────────────────

class _TimeBreakdownCard extends StatelessWidget {
  const _TimeBreakdownCard({
    required this.absDays,
    required this.isCountingUp,
    required this.targetDate,
    required this.color,
  });

  final int absDays;
  final bool isCountingUp;
  final DateTime targetDate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final years = absDays ~/ 365;
    final months = (absDays % 365) ~/ 30;
    final weeks = ((absDays % 365) % 30) ~/ 7;
    final days = ((absDays % 365) % 30) % 7;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Column(
        children: [
          Text(
            isCountingUp ? 'Da ben nhau' : 'Con lai',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TimeUnit(value: years, unit: 'Nam'),
              _TimeUnit(value: months, unit: 'Thang'),
              _TimeUnit(value: weeks, unit: 'Tuan'),
              _TimeUnit(value: days, unit: 'Ngay'),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: context.appColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Tong gio',
                value: '${absDays * 24}',
              ),
              _StatItem(
                label: 'Tong tuan',
                value: '${(absDays / 7).floor()}',
              ),
              _StatItem(
                label: 'Tong thang',
                value: '${(absDays / 30).floor()}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  const _TimeUnit({required this.value, required this.unit});

  final int value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

// ─── Section Card ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ─── Milestone Row ──────────────────────────────────────────────────────────

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.milestone,
    required this.color,
    required this.currentDays,
  });

  final DayMilestone milestone;
  final Color color;
  final int currentDays;

  String _formatTarget(int days) {
    if (days == 7) return '1 tuan';
    if (days == 30) return '1 thang';
    if (days == 50) return '50 ngay';
    if (days == 100) return '100 ngay';
    if (days == 200) return '200 ngay';
    if (days == 365) return '1 nam';
    if (days == 500) return '500 ngay';
    if (days == 730) return '2 nam';
    if (days == 1000) return '1000 ngay';
    if (days == 1095) return '3 nam';
    if (days == 1500) return '1500 ngay';
    if (days == 2000) return '2000 ngay';
    if (days == 2555) return '7 nam';
    if (days == 3650) return '10 nam';
    return '$days ngay';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReached = milestone.isReached;
    final progress = milestone.targetDays > 0
        ? (currentDays / milestone.targetDays).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isReached
              ? color.withOpacity(0.08)
              : context.appColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isReached ? color.withOpacity(0.3) : context.appColors.divider,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Status icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isReached ? color : color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isReached ? Icons.check : Icons.flag_outlined,
                    size: 16,
                    color: isReached ? Colors.white : color,
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTarget(milestone.targetDays),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isReached ? color : null,
                        ),
                      ),
                      if (!isReached)
                        Text(
                          'Con ${milestone.daysRemaining} ngay nua',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                ),

                // Percentage
                Text(
                  isReached ? 'Da dat' : '${(progress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isReached ? color : theme.colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (!isReached) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
