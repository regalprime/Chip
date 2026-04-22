import 'package:common_packages/domain/entities/love_letter/love_letter_entity.dart';
import 'package:common_packages/presentation/blocs/love_letter/love_letter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LetterDetailView extends StatefulWidget {
  final LoveLetterEntity letter;
  final bool isReceived;

  const LetterDetailView({
    super.key,
    required this.letter,
    required this.isReceived,
  });

  @override
  State<LetterDetailView> createState() => _LetterDetailViewState();
}

class _LetterDetailViewState extends State<LetterDetailView> {
  @override
  void initState() {
    super.initState();
    if (widget.isReceived &&
        widget.letter.isDelivered &&
        !widget.letter.isRead) {
      context
          .read<LoveLetterBloc>()
          .add(MarkLetterReadEvent(id: widget.letter.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final letter = widget.letter;

    if (!letter.isDelivered) {
      return _LockedView(letter: letter);
    }

    return _DeliveredView(letter: letter, isReceived: widget.isReceived);
  }
}

// ---------------------------------------------------------------------------
// Locked state -- letter not yet delivered
// ---------------------------------------------------------------------------

class _LockedView extends StatelessWidget {
  final LoveLetterEntity letter;

  const _LockedView({required this.letter});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final daysLeft = letter.daysUntilDelivery;
    final dateStr = '${letter.deliveryDate.day.toString().padLeft(2, '0')}/'
        '${letter.deliveryDate.month.toString().padLeft(2, '0')}/'
        '${letter.deliveryDate.year}';

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Thu nay se duoc mo vao ngay $dateStr',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Con $daysLeft ngay nua',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Delivered state -- show letter content
// ---------------------------------------------------------------------------

class _DeliveredView extends StatelessWidget {
  final LoveLetterEntity letter;
  final bool isReceived;

  const _DeliveredView({required this.letter, required this.isReceived});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final senderOrRecipient =
        isReceived ? letter.senderName : letter.recipientName;
    final photo = isReceived ? letter.senderPhoto : letter.recipientPhoto;
    final dateStr = '${letter.deliveryDate.day.toString().padLeft(2, '0')}/'
        '${letter.deliveryDate.month.toString().padLeft(2, '0')}/'
        '${letter.deliveryDate.year}';

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Title --
            Text(
              letter.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // -- Sender / Recipient info --
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      photo != null ? NetworkImage(photo) : null,
                  child: photo == null
                      ? Text(
                          (senderOrRecipient ?? '?')
                              .characters
                              .first
                              .toUpperCase(),
                          style: const TextStyle(fontSize: 14),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isReceived
                          ? 'Tu ${senderOrRecipient ?? 'Ai do'}'
                          : 'Gui toi ${senderOrRecipient ?? 'Ai do'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 28),

            // -- Content --
            Text(
              letter.content,
              style: const TextStyle(
                fontSize: 18,
                height: 1.8,
                fontFamily: 'Tinos',
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
