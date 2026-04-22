import 'package:common_packages/domain/entities/friendship/friendship_entity.dart';
import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/presentation/blocs/friend/friend_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendView extends StatelessWidget {
  const FriendView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bạn bè'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bạn bè'),
              Tab(text: 'Lời mời'),
              Tab(text: 'Tìm kiếm'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FriendListTab(),
            _FriendRequestsTab(),
            _SearchUsersTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 1: Danh sách bạn bè ─────────────────────────────────────────────────

class _FriendListTab extends StatelessWidget {
  const _FriendListTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendBloc, FriendState>(
      builder: (context, state) {
        if (state.status == FriendStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.friends.isEmpty) {
          return const Center(child: Text('Chưa có bạn bè nào'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<FriendBloc>().add(const LoadFriendsEvent());
          },
          child: ListView.builder(
            itemCount: state.friends.length,
            itemBuilder: (context, index) {
              final friendship = state.friends[index];
              return _FriendTile(friendship: friendship);
            },
          ),
        );
      },
    );
  }
}

class _FriendTile extends StatelessWidget {
  final FriendshipEntity friendship;

  const _FriendTile({required this.friendship});

  @override
  Widget build(BuildContext context) {
    // Hiển thị thông tin của người bạn (không phải mình)
    final friendName = friendship.requesterName ?? friendship.addresseeName ?? 'Người dùng';
    final friendPhoto = friendship.requesterPhoto ?? friendship.addresseePhoto;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: friendPhoto != null ? NetworkImage(friendPhoto) : null,
        child: friendPhoto == null ? const Icon(Icons.person) : null,
      ),
      title: Text(friendName),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'remove') {
            _confirmRemove(context);
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.person_remove, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Huỷ kết bạn', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Huỷ kết bạn'),
        content: const Text('Bạn có chắc muốn huỷ kết bạn không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FriendBloc>().add(RemoveFriendEvent(friendship.id));
            },
            child: const Text('Huỷ kết bạn', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 2: Lời mời kết bạn ──────────────────────────────────────────────────

class _FriendRequestsTab extends StatelessWidget {
  const _FriendRequestsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendBloc, FriendState>(
      builder: (context, state) {
        if (state.friendRequests.isEmpty) {
          return const Center(child: Text('Không có lời mời nào'));
        }

        return ListView.builder(
          itemCount: state.friendRequests.length,
          itemBuilder: (context, index) {
            final request = state.friendRequests[index];
            return _FriendRequestTile(request: request);
          },
        );
      },
    );
  }
}

class _FriendRequestTile extends StatelessWidget {
  final FriendshipEntity request;

  const _FriendRequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: request.requesterPhoto != null
            ? NetworkImage(request.requesterPhoto!)
            : null,
        child: request.requesterPhoto == null ? const Icon(Icons.person) : null,
      ),
      title: Text(request.requesterName ?? 'Người dùng'),
      subtitle: const Text('Muốn kết bạn với bạn'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              context.read<FriendBloc>().add(RespondFriendRequestEvent(
                    friendshipId: request.id,
                    accept: true,
                  ));
            },
            icon: const Icon(Icons.check_circle, color: Colors.green),
            tooltip: 'Chấp nhận',
          ),
          IconButton(
            onPressed: () {
              context.read<FriendBloc>().add(RespondFriendRequestEvent(
                    friendshipId: request.id,
                    accept: false,
                  ));
            },
            icon: const Icon(Icons.cancel, color: Colors.red),
            tooltip: 'Từ chối',
          ),
        ],
      ),
    );
  }
}

// ─── Tab 3: Tìm kiếm người dùng ─────────────────────────────────────────────

class _SearchUsersTab extends StatelessWidget {
  const _SearchUsersTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Tìm theo email hoặc tên...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (query) {
              context.read<FriendBloc>().add(SearchUsersEvent(query));
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<FriendBloc, FriendState>(
            builder: (context, state) {
              if (state.status == FriendStatus.searching) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.searchResults.isEmpty) {
                return const Center(child: Text('Nhập để tìm kiếm người dùng'));
              }

              return ListView.builder(
                itemCount: state.searchResults.length,
                itemBuilder: (context, index) {
                  final user = state.searchResults[index];
                  return _SearchUserTile(user: user);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchUserTile extends StatelessWidget {
  final UserEntity user;

  const _SearchUserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendBloc, FriendState>(
      builder: (context, state) {
        final isFriend = state.friends.any(
          (f) => f.requesterId == user.uid || f.addresseeId == user.uid,
        );

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null ? const Icon(Icons.person) : null,
          ),
          title: Text(user.displayName ?? user.email),
          subtitle: Text(user.email),
          trailing: isFriend
              ? const Chip(label: Text('Bạn bè'))
              : FilledButton.tonal(
                  onPressed: () {
                    context.read<FriendBloc>().add(SendFriendRequestEvent(user.uid));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã gửi lời mời kết bạn!')),
                    );
                  },
                  child: const Text('Kết bạn'),
                ),
        );
      },
    );
  }
}
