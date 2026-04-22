import 'package:common_packages/domain/entities/share/shared_item_entity.dart';
import 'package:common_packages/presentation/blocs/feed/feed_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bạn bè chia sẻ')),
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          return switch (state.status) {
            FeedStatus.loading => const Center(child: CircularProgressIndicator()),
            FeedStatus.error => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Đã xảy ra lỗi'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<FeedBloc>().add(const LoadFeedEvent()),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            _ => state.items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Chưa có ai chia sẻ gì cho bạn'),
                        SizedBox(height: 4),
                        Text(
                          'Kết bạn và chia sẻ ảnh, ghi chú với nhau!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      context.read<FeedBloc>().add(const LoadFeedEvent());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return _SharedItemCard(item: item);
                      },
                    ),
                  ),
          };
        },
      ),
    );
  }
}

class _SharedItemCard extends StatelessWidget {
  final SharedItemEntity item;

  const _SharedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - thông tin người chia sẻ
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: item.ownerPhoto != null
                      ? NetworkImage(item.ownerPhoto!)
                      : null,
                  child: item.ownerPhoto == null
                      ? const Icon(Icons.person, size: 18)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.ownerName ?? 'Người dùng',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatTime(item.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  item.itemType == SharedItemType.photo
                      ? Icons.photo
                      : Icons.note,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          // Content
          if (item.itemType == SharedItemType.photo && item.photoUrl != null)
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                item.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 48),
                ),
              ),
            )
          else if (item.itemType == SharedItemType.note)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.noteTitle != null)
                      Text(
                        item.noteTitle!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (item.noteContent != null && item.noteContent!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.noteContent!,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${date.day}/${date.month}/${date.year}';
  }
}
