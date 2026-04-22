import 'package:common_packages/presentation/blocs/qa/qa_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class QaHistoryView extends StatefulWidget {
  const QaHistoryView({super.key});

  @override
  State<QaHistoryView> createState() => _QaHistoryViewState();
}

class _QaHistoryViewState extends State<QaHistoryView> {
  @override
  void initState() {
    super.initState();
    final qaState = context.read<QaBloc>().state;
    if (qaState.selectedFriendshipId != null && qaState.selectedPartnerUid != null) {
      context.read<QaBloc>().add(LoadQaHistoryEvent(
            friendshipId: qaState.selectedFriendshipId!,
            partnerUid: qaState.selectedPartnerUid!,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lich su Q&A')),
      body: BlocBuilder<QaBloc, QaState>(
        builder: (context, state) {
          if (state.status == QaStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = state.history
              .where((entry) => entry.bothAnswered)
              .toList();

          if (history.isEmpty) {
            return const Center(
              child: Text(
                'Chua co lich su Q&A nao.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              final dateFormatted =
                  DateFormat('dd/MM/yyyy').format(entry.questionDate);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.questionText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
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
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.myAnswer?.answerText ??
                                        'Chua tra loi',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
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
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.partnerAnswer?.answerText ??
                                        'Chua tra loi',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
