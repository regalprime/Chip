import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:common_packages/domain/entities/note/note_entity.dart';
import 'package:common_packages/presentation/blocs/note/note_bloc.dart';
import 'package:common_packages/presentation/pages/share/share_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteView extends StatelessWidget {
  const NoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteBloc, NoteState>(
      listener: (context, state) {
        if (state.status == NoteStatus.error) {
          DSErrorDialog.show(context, message: state.errorMessage ?? 'Đã xảy ra lỗi');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Ghi chú')),
        body: BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            return switch (state.status) {
              NoteStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
              NoteStatus.error => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ?? 'Đã xảy ra lỗi',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<NoteBloc>().add(const LoadNotesEvent()),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              _ => state.notes.isEmpty
                  ? const Center(child: Text('Chưa có ghi chú nào'))
                  : Stack(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: state.notes.length,
                          itemBuilder: (context, index) {
                            final note = state.notes[index];
                            return _NoteCard(note: note);
                          },
                        ),
                        if (state.status == NoteStatus.saving)
                          Container(
                            color: Colors.black26,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
            };
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showNoteEditor(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showNoteEditor(BuildContext context, {NoteEntity? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    final isEditing = note != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Sửa ghi chú' : 'Thêm ghi chú',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final content = contentController.text.trim();
                if (title.isEmpty) return;

                if (isEditing) {
                  context.read<NoteBloc>().add(UpdateNoteEvent(
                        id: note.id,
                        title: title,
                        content: content,
                      ));
                } else {
                  context.read<NoteBloc>().add(AddNoteEvent(
                        title: title,
                        content: content,
                      ));
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteEntity note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showNoteDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'share') {
                        ShareDialog.show(context, itemId: note.id, itemType: 'note');
                      } else if (value == 'edit') {
                        _editNote(context);
                      } else if (value == 'delete') {
                        _confirmDelete(context);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 20),
                            SizedBox(width: 8),
                            Text('Chia sẻ'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xoá', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  note.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _formatDate(note.updatedAt),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoteDetail(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                note.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(note.updatedAt),
                style: theme.textTheme.bodySmall,
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    note.content.isEmpty ? 'Không có nội dung' : note.content,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editNote(BuildContext context) {
    // Access the parent NoteView's _showNoteEditor via the bloc context
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sửa ghi chú',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final content = contentController.text.trim();
                if (title.isEmpty) return;

                context.read<NoteBloc>().add(UpdateNoteEvent(
                      id: note.id,
                      title: title,
                      content: content,
                    ));
                Navigator.pop(context);
              },
              child: const Text('Cập nhật'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: const Text('Bạn có chắc muốn xoá ghi chú này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<NoteBloc>().add(DeleteNoteEvent(note.id));
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
