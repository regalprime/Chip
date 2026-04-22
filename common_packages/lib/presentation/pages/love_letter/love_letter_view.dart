import 'package:common_packages/domain/entities/love_letter/love_letter_entity.dart';
import 'package:common_packages/presentation/blocs/love_letter/love_letter_bloc.dart';
import 'package:common_packages/presentation/pages/love_letter/send_letter_sheet.dart';
import 'package:common_packages/presentation/pages/love_letter/letter_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoveLetterView extends StatefulWidget {
  const LoveLetterView({super.key});

  @override
  State<LoveLetterView> createState() => _LoveLetterViewState();
}

class _LoveLetterViewState extends State<LoveLetterView> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<LoveLetterBloc>();
    bloc.add(LoadSentLettersEvent());
    bloc.add(LoadReceivedLettersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thu tinh'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Da gui'),
              Tab(text: 'Da nhan'),
            ],
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
          ),
        ),
        body: BlocConsumer<LoveLetterBloc, LoveLetterState>(
          listener: (context, state) {
            if (state.status == LoveLetterStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            return TabBarView(
              children: [
                _SentTab(
                  letters: state.sentLetters,
                  isLoading: state.status == LoveLetterStatus.loading,
                ),
                _ReceivedTab(
                  letters: state.receivedLetters,
                  isLoading: state.status == LoveLetterStatus.loading,
                ),
              ],
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                if (tabController.index == 0) {
                  return FloatingActionButton(
                    onPressed: () => _openComposeSheet(context),
                    child: const Icon(Icons.edit),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  void _openComposeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<LoveLetterBloc>(),
        child: const SendLetterSheet(friends: []),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sent tab
// ---------------------------------------------------------------------------

class _SentTab extends StatelessWidget {
  final List<LoveLetterEntity> letters;
  final bool isLoading;

  const _SentTab({required this.letters, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<LoveLetterBloc>().add(LoadSentLettersEvent());
      },
      child: isLoading && letters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : letters.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 200),
                    Center(
                      child: Text(
                        'Chua co thu nao',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: letters.length,
                  itemBuilder: (context, index) {
                    final letter = letters[index];
                    return _SentLetterCard(letter: letter);
                  },
                ),
    );
  }
}

class _SentLetterCard extends StatelessWidget {
  final LoveLetterEntity letter;

  const _SentLetterCard({required this.letter});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDelivered = letter.isDelivered;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<LoveLetterBloc>(),
                child: LetterDetailView(
                  letter: letter,
                  isReceived: false,
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: letter.recipientPhoto != null
                    ? NetworkImage(letter.recipientPhoto!)
                    : null,
                child: letter.recipientPhoto == null
                    ? Text(
                        (letter.recipientName ?? '?')
                            .characters
                            .first
                            .toUpperCase(),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      letter.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gui toi ${letter.recipientName ?? 'Ai do'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(letter.deliveryDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(isDelivered: isDelivered),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Received tab
// ---------------------------------------------------------------------------

class _ReceivedTab extends StatelessWidget {
  final List<LoveLetterEntity> letters;
  final bool isLoading;

  const _ReceivedTab({required this.letters, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<LoveLetterBloc>().add(LoadReceivedLettersEvent());
      },
      child: isLoading && letters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : letters.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 200),
                    Center(
                      child: Text(
                        'Chua nhan duoc thu nao',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: letters.length,
                  itemBuilder: (context, index) {
                    final letter = letters[index];
                    return _ReceivedLetterCard(letter: letter);
                  },
                ),
    );
  }
}

class _ReceivedLetterCard extends StatelessWidget {
  final LoveLetterEntity letter;

  const _ReceivedLetterCard({required this.letter});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDelivered = letter.isDelivered;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isDelivered) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<LoveLetterBloc>(),
                  child: LetterDetailView(
                    letter: letter,
                    isReceived: true,
                  ),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Thu nay se duoc mo sau ${letter.daysUntilDelivery} ngay nua',
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: letter.senderPhoto != null
                    ? NetworkImage(letter.senderPhoto!)
                    : null,
                child: letter.senderPhoto == null
                    ? Text(
                        (letter.senderName ?? '?')
                            .characters
                            .first
                            .toUpperCase(),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDelivered
                          ? letter.title
                          : '???',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tu ${letter.senderName ?? 'Ai do'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(letter.deliveryDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!isDelivered)
                Icon(
                  Icons.lock_outline,
                  color: colorScheme.onSurfaceVariant,
                  size: 22,
                )
              else
                _StatusChip(isDelivered: true),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets & helpers
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  final bool isDelivered;

  const _StatusChip({required this.isDelivered});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDelivered
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDelivered ? 'Da giao' : 'Dang cho',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDelivered ? Colors.green.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
