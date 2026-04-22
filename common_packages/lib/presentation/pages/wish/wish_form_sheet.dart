import 'package:common_packages/domain/entities/wish/wish_entity.dart';
import 'package:common_packages/presentation/blocs/wish/wish_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishFormSheet extends StatefulWidget {
  const WishFormSheet({super.key, this.wish});

  final WishEntity? wish;

  @override
  State<WishFormSheet> createState() => _WishFormSheetState();
}

class _WishFormSheetState extends State<WishFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedEmoji;

  bool get _isEditing => widget.wish != null;

  final _formKey = GlobalKey<FormState>();

  static const _emojiOptions = ['⭐', '🌟', '💫', '✨', '🎯', '💝', '🌈', '🦋'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.wish?.title ?? '');
    _descriptionController = TextEditingController(text: widget.wish?.description ?? '');
    _selectedEmoji = widget.wish?.emoji ?? '⭐';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final bloc = context.read<WishBloc>();

    if (_isEditing) {
      bloc.add(UpdateWishEvent(
        id: widget.wish!.id,
        title: title,
        description: description.isNotEmpty ? description : null,
        emoji: _selectedEmoji,
      ));
    } else {
      bloc.add(AddWishEvent(
        title: title,
        description: description.isNotEmpty ? description : null,
        emoji: _selectedEmoji,
      ));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'Chinh sua dieu uoc' : 'Them dieu uoc',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      TextFormField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: 'Dieu uoc',
                          hintText: 'VD: Du lich Nhat Ban',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Vui long nhap dieu uoc';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: 'Mo ta (tuy chon)',
                          hintText: 'VD: Di vao mua hoa anh dao...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Emoji picker
                      Text(
                        'Bieu tuong',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _emojiOptions.map((emoji) {
                          final isSelected = emoji == _selectedEmoji;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedEmoji = emoji),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surfaceContainerHighest
                                        .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _submit,
                          child: Text(_isEditing ? 'Cap nhat' : 'Luu dieu uoc'),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
