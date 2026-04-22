import 'package:common_packages/base/extensions/context_extension.dart';
import 'package:common_packages/presentation/blocs/counter_day/day_counter_bloc.dart';
import 'package:common_packages/presentation/blocs/document_reader/document_reader_bloc.dart';
import 'package:common_packages/presentation/blocs/finance/finance_bloc.dart';
import 'package:common_packages/presentation/blocs/friend/friend_bloc.dart';
import 'package:common_packages/presentation/blocs/love_letter/love_letter_bloc.dart';
import 'package:common_packages/presentation/blocs/note/note_bloc.dart';
import 'package:common_packages/presentation/blocs/wish/wish_bloc.dart';
import 'package:common_packages/presentation/pages/counter_day/day_counter_view.dart';
import 'package:common_packages/presentation/pages/document_reader/document_library_view.dart';
import 'package:common_packages/presentation/pages/finance/finance_view.dart';
import 'package:common_packages/presentation/pages/love_letter/love_letter_view.dart';
import 'package:common_packages/presentation/pages/note/note_view.dart';
import 'package:common_packages/presentation/pages/wish/wish_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ToolsView extends StatelessWidget {
  const ToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cong cu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _ToolCard(
              icon: Icons.note_alt_outlined,
              label: 'Ghi chu',
              color: const Color(0xFF42A5F5),
              onTap: () => _push(
                context,
                BlocProvider.value(
                  value: context.read<NoteBloc>(),
                  child: const NoteView(),
                ),
              ),
            ),
            _ToolCard(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Thu chi',
              color: const Color(0xFF66BB6A),
              onTap: () => _push(
                context,
                BlocProvider.value(
                  value: context.read<FinanceBloc>(),
                  child: const FinanceView(),
                ),
              ),
            ),
            _ToolCard(
              icon: Icons.favorite_border,
              label: 'Dem ngay',
              color: const Color(0xFFEF5350),
              onTap: () => _push(
                context,
                BlocProvider.value(
                  value: context.read<DayCounterBloc>(),
                  child: const DayCounterView(),
                ),
              ),
            ),
            _ToolCard(
              icon: Icons.menu_book_outlined,
              label: 'Doc sach',
              color: const Color(0xFFAB47BC),
              onTap: () => _push(
                context,
                BlocProvider.value(
                  value: context.read<DocumentReaderBloc>(),
                  child: const DocumentLibraryView(),
                ),
              ),
            ),
            _ToolCard(
              icon: Icons.auto_awesome_outlined,
              label: 'Dieu uoc',
              color: const Color(0xFFFFCA28),
              onTap: () => _push(
                context,
                BlocProvider.value(
                  value: context.read<WishBloc>(),
                  child: const WishView(),
                ),
              ),
            ),
            _ToolCard(
              icon: Icons.mail_outline,
              label: 'Thu tinh',
              color: const Color(0xFFEC407A),
              onTap: () => _push(
                context,
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<LoveLetterBloc>()),
                    BlocProvider.value(value: context.read<FriendBloc>()),
                  ],
                  child: const LoveLetterView(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.appColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
