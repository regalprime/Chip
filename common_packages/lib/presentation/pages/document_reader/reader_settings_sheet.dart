import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/document_reader/document_reader_bloc.dart';

class ReaderSettingsSheet extends StatelessWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<DocumentReaderBloc, DocumentReaderState>(
      buildWhen: (prev, curr) => prev.settings != curr.settings,
      builder: (context, state) {
        final settings = state.settings;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Cai dat doc',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),

              // Font size
              Text(
                'Co chu',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('A', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: settings.fontSize,
                      min: 10,
                      max: 40,
                      divisions: 15,
                      label: '${settings.fontSize.toInt()}',
                      onChanged: (v) {
                        context.read<DocumentReaderBloc>().add(
                              UpdateReaderSettingsEvent(fontSize: v),
                            );
                      },
                    ),
                  ),
                  const Text('A', style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 16),

              // Line height
              Text(
                'Khoang cach dong',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.density_small, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  Expanded(
                    child: Slider(
                      value: settings.lineHeight,
                      min: 1.0,
                      max: 2.5,
                      divisions: 15,
                      label: settings.lineHeight.toStringAsFixed(1),
                      onChanged: (v) {
                        context.read<DocumentReaderBloc>().add(
                              UpdateReaderSettingsEvent(lineHeight: v),
                            );
                      },
                    ),
                  ),
                  Icon(Icons.density_large, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ],
              ),
              const SizedBox(height: 16),

              // Reader theme
              Text(
                'Nen doc',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ThemeOption(
                    label: 'Sang',
                    backgroundColor: const Color(0xFFFAFAFA),
                    textColor: const Color(0xFF2C2C2C),
                    isSelected: settings.readerTheme == ReaderTheme.light,
                    onTap: () => context.read<DocumentReaderBloc>().add(
                          const UpdateReaderSettingsEvent(readerTheme: ReaderTheme.light),
                        ),
                  ),
                  const SizedBox(width: 12),
                  _ThemeOption(
                    label: 'Sepia',
                    backgroundColor: const Color(0xFFF5E6CA),
                    textColor: const Color(0xFF4A3728),
                    isSelected: settings.readerTheme == ReaderTheme.sepia,
                    onTap: () => context.read<DocumentReaderBloc>().add(
                          const UpdateReaderSettingsEvent(readerTheme: ReaderTheme.sepia),
                        ),
                  ),
                  const SizedBox(width: 12),
                  _ThemeOption(
                    label: 'Toi',
                    backgroundColor: const Color(0xFF1A1A1A),
                    textColor: const Color(0xFFD4D4D4),
                    isSelected: settings.readerTheme == ReaderTheme.dark,
                    onTap: () => context.read<DocumentReaderBloc>().add(
                          const UpdateReaderSettingsEvent(readerTheme: ReaderTheme.dark),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _previewBg(settings.readerTheme),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Text(
                  'Day la van ban mau de xem truoc. Ban co the thay doi co chu va khoang cach dong cho phu hop.',
                  style: TextStyle(
                    fontSize: settings.fontSize,
                    height: settings.lineHeight,
                    color: _previewText(settings.readerTheme),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Color _previewBg(ReaderTheme t) {
    switch (t) {
      case ReaderTheme.light:
        return const Color(0xFFFAFAFA);
      case ReaderTheme.sepia:
        return const Color(0xFFF5E6CA);
      case ReaderTheme.dark:
        return const Color(0xFF1A1A1A);
    }
  }

  Color _previewText(ReaderTheme t) {
    switch (t) {
      case ReaderTheme.light:
        return const Color(0xFF2C2C2C);
      case ReaderTheme.sepia:
        return const Color(0xFF4A3728);
      case ReaderTheme.dark:
        return const Color(0xFFD4D4D4);
    }
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
