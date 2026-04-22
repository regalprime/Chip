import 'package:common_packages/domain/entities/day_counter/day_counter_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/counter_day/day_counter_bloc.dart';

class DayCounterFormSheet extends StatefulWidget {
  const DayCounterFormSheet({super.key, this.counter});

  final DayCounterEntity? counter;

  @override
  State<DayCounterFormSheet> createState() => _DayCounterFormSheetState();
}

class _DayCounterFormSheetState extends State<DayCounterFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late DateTime _selectedDate;
  late String _selectedEmoji;
  late String _selectedColorHex;

  bool get _isEditing => widget.counter != null;

  final _formKey = GlobalKey<FormState>();

  static const _emojiOptions = [
    '❤️', '💕', '💖', '💗', '💝', '🥰', '😍', '💑',
    '🎂', '🎉', '🎓', '💍', '🏠', '👶', '✈️', '⭐',
  ];

  static const _colorOptions = [
    'FFD32F2F', // Red
    'FFE91E63', // Pink
    'FF9C27B0', // Purple
    'FF673AB7', // Deep Purple
    'FF3F51B5', // Indigo
    'FF2196F3', // Blue
    'FF00BCD4', // Cyan
    'FF009688', // Teal
    'FF4CAF50', // Green
    'FF8BC34A', // Light Green
    'FFFF9800', // Orange
    'FF795548', // Brown
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.counter?.title ?? '');
    _noteController = TextEditingController(text: widget.counter?.note ?? '');
    _selectedDate = widget.counter?.targetDate ?? DateTime.now();
    _selectedEmoji = widget.counter?.emoji ?? '❤️';
    _selectedColorHex = widget.counter?.colorHex ?? 'FFD32F2F';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final note = _noteController.text.trim();
    final bloc = context.read<DayCounterBloc>();

    if (_isEditing) {
      bloc.add(UpdateDayCounterEvent(
        id: widget.counter!.id,
        title: title,
        targetDate: _selectedDate,
        emoji: _selectedEmoji,
        colorHex: _selectedColorHex,
        note: note.isNotEmpty ? note : null,
      ));
    } else {
      bloc.add(AddDayCounterEvent(
        title: title,
        targetDate: _selectedDate,
        emoji: _selectedEmoji,
        colorHex: _selectedColorHex,
        note: note.isNotEmpty ? note : null,
      ));
    }

    Navigator.of(context).pop();
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return const Color(0xFFD32F2F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
                      _isEditing ? 'Chinh sua' : 'Them ngay moi',
                      style: theme.textTheme.headlineLarge,
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
                        labelText: 'Ten',
                        hintText: 'VD: Ngay yeu nhau',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Vui long nhap ten';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date picker
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Ngay',
                          prefixIcon: const Icon(Icons.calendar_today, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Emoji picker
                    Text('Bieu tuong', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
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
                                  : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(emoji, style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Color picker
                    Text('Mau sac', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _colorOptions.map((hex) {
                        final color = _parseColor(hex);
                        final isSelected = hex == _selectedColorHex;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColorHex = hex),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                                  : null,
                              boxShadow: isSelected
                                  ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Note field
                    TextFormField(
                      controller: _noteController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Ghi chu (tuy chon)',
                        hintText: 'VD: Ngay dau tien gap nhau...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Preview
                    _MiniPreview(
                      emoji: _selectedEmoji,
                      title: _titleController.text.isNotEmpty
                          ? _titleController.text
                          : 'Ten su kien',
                      color: _parseColor(_selectedColorHex),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submit,
                        child: Text(_isEditing ? 'Cap nhat' : 'Tao moi'),
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
    );
  }
}

class _MiniPreview extends StatelessWidget {
  const _MiniPreview({
    required this.emoji,
    required this.title,
    required this.color,
  });

  final String emoji;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xem truoc',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
