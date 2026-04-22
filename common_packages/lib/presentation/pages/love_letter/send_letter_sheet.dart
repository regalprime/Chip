import 'package:common_packages/presentation/blocs/love_letter/love_letter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendInfo {
  final String uid;
  final String name;
  final String? photoUrl;
  const FriendInfo({required this.uid, required this.name, this.photoUrl});
}

class SendLetterSheet extends StatefulWidget {
  final List<FriendInfo> friends;

  const SendLetterSheet({super.key, required this.friends});

  @override
  State<SendLetterSheet> createState() => _SendLetterSheetState();
}

class _SendLetterSheetState extends State<SendLetterSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  FriendInfo? _selectedFriend;
  DateTime? _deliveryDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() => _deliveryDate = picked);
    }
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFriend == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hay chon nguoi nhan')),
      );
      return;
    }
    if (_deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hay chon ngay giao thu')),
      );
      return;
    }

    context.read<LoveLetterBloc>().add(
          SendLetterEvent(
            recipientId: _selectedFriend!.uid,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            deliveryDate: _deliveryDate!,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viet thu tinh'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _send,
              child: const Text('Gui'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // -- Friend picker --
            Text(
              'Gui toi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.friends.isEmpty)
              Text(
                'Khong co ban be nao',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              )
            else
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.friends.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final friend = widget.friends[index];
                    final isSelected = _selectedFriend?.uid == friend.uid;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedFriend = friend),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: isSelected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                            child: CircleAvatar(
                              radius: isSelected ? 23 : 26,
                              backgroundImage: friend.photoUrl != null
                                  ? NetworkImage(friend.photoUrl!)
                                  : null,
                              child: friend.photoUrl == null
                                  ? Text(
                                      friend.name.characters.first
                                          .toUpperCase(),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            friend.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // -- Title --
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tieu de',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Hay nhap tieu de';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // -- Content --
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Noi dung thu',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              minLines: 8,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Hay nhap noi dung thu';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // -- Delivery date --
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Ngay giao thu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  _deliveryDate != null
                      ? '${_deliveryDate!.day.toString().padLeft(2, '0')}/'
                          '${_deliveryDate!.month.toString().padLeft(2, '0')}/'
                          '${_deliveryDate!.year}'
                      : 'Chon ngay',
                  style: TextStyle(
                    color: _deliveryDate != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
