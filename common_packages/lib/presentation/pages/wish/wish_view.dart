import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:common_packages/base/extensions/context_extension.dart';
import 'package:common_packages/domain/entities/wish/wish_entity.dart';
import 'package:common_packages/presentation/blocs/wish/wish_bloc.dart';
import 'package:common_packages/presentation/pages/wish/wish_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishView extends StatefulWidget {
  const WishView({super.key});

  @override
  State<WishView> createState() => _WishViewState();
}

class _WishViewState extends State<WishView> {
  @override
  void initState() {
    super.initState();
    context.read<WishBloc>().add(const LoadWishesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dieu uoc'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dang uoc'),
              Tab(text: 'Da dat'),
            ],
          ),
        ),
        body: BlocConsumer<WishBloc, WishState>(
          listener: (context, state) {
            if (state.status == WishStatus.error) {
              DSErrorDialog.show(context, message: state.errorMessage ?? 'Error');
            }
          },
          builder: (context, state) {
            if (state.status == WishStatus.loading && state.wishes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _WishList(
                  wishes: state.pendingWishes,
                  emptyIcon: Icons.auto_awesome,
                  emptyText: 'Chua co dieu uoc nao',
                  isPending: true,
                  onEdit: (wish) => _openFormSheet(context, wish: wish),
                ),
                _WishList(
                  wishes: state.completedWishes,
                  emptyIcon: Icons.check_circle_outline,
                  emptyText: 'Chua dat duoc dieu uoc nao',
                  isPending: false,
                  onEdit: (wish) => _openFormSheet(context, wish: wish),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openFormSheet(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _openFormSheet(BuildContext context, {WishEntity? wish}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WishBloc>(),
        child: WishFormSheet(wish: wish),
      ),
    );
  }
}

class _WishList extends StatelessWidget {
  const _WishList({
    required this.wishes,
    required this.emptyIcon,
    required this.emptyText,
    required this.isPending,
    this.onEdit,
  });

  final List<WishEntity> wishes;
  final IconData emptyIcon;
  final String emptyText;
  final bool isPending;
  final void Function(WishEntity wish)? onEdit;

  @override
  Widget build(BuildContext context) {
    if (wishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 56, color: context.appColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              emptyText,
              style: TextStyle(
                color: context.appColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<WishBloc>().add(const LoadWishesEvent());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: wishes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final wish = wishes[index];
          return _WishCard(
            wish: wish,
            isPending: isPending,
            onEdit: onEdit,
          );
        },
      ),
    );
  }
}

class _WishCard extends StatelessWidget {
  const _WishCard({
    required this.wish,
    required this.isPending,
    this.onEdit,
  });

  final WishEntity wish;
  final bool isPending;
  final void Function(WishEntity wish)? onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showPopupMenu(context, details.globalPosition);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.appColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appColors.divider),
        ),
        child: Row(
          children: [
            Text(wish.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wish.title,
                    style: context.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: wish.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (wish.description != null && wish.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        wish.description!,
                        style: TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Checkbox(
              value: wish.isCompleted,
              onChanged: (_) {
                final bloc = context.read<WishBloc>();
                if (wish.isCompleted) {
                  bloc.add(UncompleteWishEvent(id: wish.id));
                } else {
                  bloc.add(CompleteWishEvent(id: wish.id));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context, Offset position) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(value: 'edit', child: Text('Chinh sua')),
        const PopupMenuItem(value: 'delete', child: Text('Xoa')),
      ],
    ).then((value) {
      if (value == null) return;
      if (value == 'edit') {
        onEdit?.call(wish);
      } else if (value == 'delete') {
        context.read<WishBloc>().add(DeleteWishEvent(id: wish.id));
      }
    });
  }
}
