import 'dart:io';

import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:common_packages/base/extensions/context_extension.dart';
import 'package:common_packages/domain/entities/moment/moment_entity.dart';
import 'package:common_packages/presentation/blocs/moment/moment_bloc.dart';
import 'package:common_packages/presentation/pages/moment/send_moment_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MomentView extends StatefulWidget {
  const MomentView({super.key});

  @override
  State<MomentView> createState() => _MomentViewState();
}

class _MomentViewState extends State<MomentView> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<MomentBloc>().add(const LoadMomentsEvent());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MomentBloc, MomentState>(
        listener: (context, state) {
          if (state.status == MomentStatus.sent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Moment sent!')),
            );
          }
          if (state.status == MomentStatus.error) {
            DSErrorDialog.show(context, message: state.errorMessage ?? 'Error');
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Content
              if (state.status == MomentStatus.loading && state.moments.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (state.moments.isEmpty)
                _EmptyMomentView(onSend: () => _openSendSheet(context))
              else
                RefreshIndicator(
                  onRefresh: () async {
                    context.read<MomentBloc>().add(const LoadMomentsEvent());
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: state.moments.length,
                    itemBuilder: (context, index) {
                      return _MomentCard(moment: state.moments[index]);
                    },
                  ),
                ),

              // Top bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Moments',
                        style: context.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          context.read<MomentBloc>().add(const LoadMomentsEvent());
                        },
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom camera button
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _openSendSheet(context),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: context.primaryColor.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: context.colorScheme.onPrimary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openSendSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<MomentBloc>(),
        child: const SendMomentSheet(),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyMomentView extends StatelessWidget {
  final VoidCallback onSend;

  const _EmptyMomentView({required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_camera_rounded, size: 80, color: context.appColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Chia se tam trang cua ban!',
            style: context.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Chup anh, viet tam trang\nva chia se voi ban be',
            style: TextStyle(color: context.appColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onSend,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Gui moment dau tien'),
          ),
        ],
      ),
    );
  }
}

// ─── Moment Card (full-screen, Locket-style) ─────────────────────────────────

class _MomentCard extends StatelessWidget {
  final MomentEntity moment;

  const _MomentCard({required this.moment});

  @override
  Widget build(BuildContext context) {
    final hasImage = moment.imageUrl != null;
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: context.isDarkMode ? Colors.black : context.surfaceColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          if (hasImage)
            Image.network(
              moment.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: context.primaryColor.withOpacity(0.1),
                child: const Center(child: Icon(Icons.broken_image, size: 64)),
              ),
            )
          else
            // Gradient background for text-only moments
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.primaryColor.withOpacity(0.8),
                    context.colorScheme.secondary.withOpacity(0.6),
                  ],
                ),
              ),
            ),

          // Gradient overlay for readability
          if (hasImage)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.3, 0.5, 1.0],
                ),
              ),
            ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 120),
              child: Column(
                children: [
                  const Spacer(),

                  // Mood emoji
                  if (moment.mood != null) ...[
                    Text(
                      moment.mood!,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Content text
                  if (moment.content != null && moment.content!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        moment.content!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // User info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: moment.userPhoto != null
                            ? NetworkImage(moment.userPhoto!)
                            : null,
                        child: moment.userPhoto == null
                            ? const Icon(Icons.person, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        moment.userName ?? 'User',
                        style: TextStyle(
                          color: hasImage ? Colors.white : Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(moment.createdAt),
                        style: TextStyle(
                          color: hasImage ? Colors.white70 : Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Reactions
                  _ReactionBar(moment: moment),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Vua xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}';
  }
}

// ─── Reaction bar ─────────────────────────────────────────────────────────────

class _ReactionBar extends StatelessWidget {
  final MomentEntity moment;

  const _ReactionBar({required this.moment});

  static const _emojis = ['❤️', '🔥', '😂', '😢', '😍', '👏'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Existing reactions
        if (moment.reactions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 4,
              children: _groupedReactions().entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${entry.key} ${entry.value}',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ),

        // Emoji picker row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _emojis.map((emoji) {
              return GestureDetector(
                onTap: () {
                  context.read<MomentBloc>().add(ReactToMomentEvent(
                    momentId: moment.id,
                    emoji: emoji,
                  ));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Map<String, int> _groupedReactions() {
    final map = <String, int>{};
    for (final r in moment.reactions) {
      map[r.emoji] = (map[r.emoji] ?? 0) + 1;
    }
    return map;
  }
}
