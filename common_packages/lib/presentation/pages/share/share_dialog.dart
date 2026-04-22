import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:common_packages/domain/entities/friendship/friendship_entity.dart';
import 'package:common_packages/presentation/blocs/feed/feed_bloc.dart';
import 'package:common_packages/presentation/blocs/friend/friend_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShareDialog extends StatelessWidget {
  final String itemId;
  final String itemType; // 'photo' or 'note'

  const ShareDialog({
    super.key,
    required this.itemId,
    required this.itemType,
  });

  static Future<void> show(BuildContext context, {required String itemId, required String itemType}) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<FriendBloc>()),
          BlocProvider.value(value: context.read<FeedBloc>()),
        ],
        child: ShareDialog(itemId: itemId, itemType: itemType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state.status == FeedStatus.shared) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã chia sẻ thành công!')),
          );
        }
        if (state.status == FeedStatus.error) {
          DSErrorDialog.show(context, message: state.errorMessage ?? 'Chia sẻ thất bại');
        }
      },
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Chia sẻ với bạn bè',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            BlocBuilder<FriendBloc, FriendState>(
              builder: (context, state) {
                if (state.friends.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Bạn chưa có bạn bè nào')),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.friends.length,
                  itemBuilder: (context, index) {
                    final friendship = state.friends[index];
                    return _FriendShareTile(
                      friendship: friendship,
                      onShare: (friendId) {
                        context.read<FeedBloc>().add(ShareItemEvent(
                              friendId: friendId,
                              itemId: itemId,
                              itemType: itemType,
                            ));
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FriendShareTile extends StatelessWidget {
  final FriendshipEntity friendship;
  final void Function(String friendId) onShare;

  const _FriendShareTile({
    required this.friendship,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final friendName = friendship.requesterName ?? friendship.addresseeName ?? 'Người dùng';
    final friendPhoto = friendship.requesterPhoto ?? friendship.addresseePhoto;
    // Xác định ID của bạn (không phải mình)
    final friendId = friendship.addresseeId;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: friendPhoto != null ? NetworkImage(friendPhoto) : null,
        child: friendPhoto == null ? const Icon(Icons.person) : null,
      ),
      title: Text(friendName),
      trailing: FilledButton.tonal(
        onPressed: () => onShare(friendId),
        child: const Text('Gửi'),
      ),
    );
  }
}
