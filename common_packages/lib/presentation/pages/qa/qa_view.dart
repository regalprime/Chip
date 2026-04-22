import 'package:common_packages/presentation/blocs/auth/auth_bloc.dart';
import 'package:common_packages/presentation/blocs/friend/friend_bloc.dart';
import 'package:common_packages/presentation/blocs/qa/qa_bloc.dart';
import 'package:common_packages/presentation/pages/qa/qa_history_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QaView extends StatefulWidget {
  const QaView({super.key});

  @override
  State<QaView> createState() => _QaViewState();
}

class _QaViewState extends State<QaView> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  String _getMyUid(BuildContext context) {
    final authState = context.read<AuthBloc>().state as AuthAuthenticated;
    return authState.user.uid;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QaBloc, QaState>(
      builder: (context, state) {
        if (state.selectedFriendshipId == null) {
          return _buildFriendPicker(context);
        }

        if (state.status == QaStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.todayQuestion == null) {
          return const Center(child: Text('Khong co cau hoi hom nay.'));
        }

        return _buildQuestionCard(context, state);
      },
    );
  }

  Widget _buildFriendPicker(BuildContext context) {
    return BlocBuilder<FriendBloc, FriendState>(
      builder: (context, friendState) {
        final friends = friendState.friends;

        if (friends.isEmpty) {
          return const Center(
            child: Text(
              'Ban chua co ban be nao.\nHay ket ban truoc khi choi Q&A!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Chon ban be de choi Q&A',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friendship = friends[index];
                  final myUid = _getMyUid(context);
                  final partnerUid = friendship.requesterId == myUid
                      ? friendship.addresseeId
                      : friendship.requesterId;

                  final partnerName = friendship.requesterId == myUid
                      ? friendship.addresseeName
                      : friendship.requesterName;
                  final partnerPhoto = friendship.requesterId == myUid
                      ? friendship.addresseePhoto
                      : friendship.requesterPhoto;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: partnerPhoto != null
                          ? NetworkImage(partnerPhoto)
                          : null,
                      child: partnerPhoto == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(partnerName ?? 'Ban be'),
                    onTap: () {
                      context.read<QaBloc>().add(
                            SelectFriendForQaEvent(
                              friendshipId: friendship.id,
                              partnerUid: partnerUid,
                            ),
                          );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuestionCard(BuildContext context, QaState state) {
    final question = state.todayQuestion!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAnswerSection(context, question),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<QaBloc>(),
                    child: const QaHistoryView(),
                  ),
                ),
              );
            },
            child: const Text('Xem lich su'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection(BuildContext context, dynamic question) {
    if (question.bothAnswered) {
      return _buildBothAnswers(question);
    }

    if (question.iAnswered) {
      return _buildWaitingForPartner(question);
    }

    return _buildAnswerInput(context);
  }

  Widget _buildAnswerInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _answerController,
          decoration: const InputDecoration(
            hintText: 'Nhap cau tra loi cua ban...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () {
            final answer = _answerController.text.trim();
            if (answer.isNotEmpty) {
              final state = context.read<QaBloc>().state;
              final q = state.todayQuestion!;
              context.read<QaBloc>().add(SubmitQaAnswerEvent(
                    friendshipId: q.friendshipId,
                    questionIndex: q.questionIndex,
                    questionDate: q.questionDate,
                    answerText: answer,
                  ));
              _answerController.clear();
            }
          },
          child: const Text('Gui'),
        ),
      ],
    );
  }

  Widget _buildWaitingForPartner(dynamic question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            question.myAnswer!.answerText,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ban da tra loi! Dang doi nguoi kia...',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBothAnswers(dynamic question) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ban',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(question.myAnswer!.answerText),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nguoi ay',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(question.partnerAnswer!.answerText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
