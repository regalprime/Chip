import 'dart:io';

import 'package:common_packages/base/extensions/context_extension.dart';
import 'package:common_packages/presentation/blocs/moment/moment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class SendMomentSheet extends StatefulWidget {
  const SendMomentSheet({super.key});

  @override
  State<SendMomentSheet> createState() => _SendMomentSheetState();
}

class _SendMomentSheetState extends State<SendMomentSheet> {
  final _contentController = TextEditingController();
  final _picker = ImagePicker();
  String? _imagePath;
  String? _selectedMood;

  static const _moods = [
    '😊', '😍', '🥰', '😂', '🤔',
    '😢', '😡', '🥳', '😴', '🤩',
    '😎', '🥺', '💪', '🔥', '❤️',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode ? context.surfaceColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocListener<MomentBloc, MomentState>(
        listener: (context, state) {
          if (state.status == MomentStatus.sent) {
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20, 12, 20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.appColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text('Chia se moment', style: context.headlineLarge),
                const SizedBox(height: 20),

                // Image preview / picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.appColors.divider),
                      image: _imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _imagePath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 48,
                                color: context.appColors.textSecondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Them anh (tuy chon)',
                                style: TextStyle(color: context.appColors.textSecondary),
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: GestureDetector(
                                onTap: () => setState(() => _imagePath = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Mood picker
                Text('Tam trang', style: context.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _moods.length,
                    itemBuilder: (context, index) {
                      final mood = _moods[index];
                      final isSelected = mood == _selectedMood;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMood = isSelected ? null : mood;
                          });
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.primaryColor.withOpacity(0.15)
                                : context.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: context.primaryColor, width: 2)
                                : Border.all(color: context.appColors.divider),
                          ),
                          child: Center(
                            child: Text(mood, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Content text
                TextField(
                  controller: _contentController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Ban dang nghi gi?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Send button
                BlocBuilder<MomentBloc, MomentState>(
                  builder: (context, state) {
                    final isSending = state.status == MomentStatus.sending;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: isSending ? null : _sendMoment,
                        child: isSending
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Gui moment', style: TextStyle(fontSize: 16)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thu vien'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final image = await _picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  void _sendMoment() {
    final content = _contentController.text.trim();

    if (content.isEmpty && _imagePath == null && _selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hay them noi dung, anh hoac tam trang!')),
      );
      return;
    }

    context.read<MomentBloc>().add(SendMomentEvent(
      content: content.isNotEmpty ? content : null,
      imagePath: _imagePath,
      mood: _selectedMood,
    ));
  }
}
