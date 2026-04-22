import 'package:flutter/material.dart';

/// A placeholder widget shown when content is empty.
///
/// Usage:
/// ```dart
/// DSEmptyState(
///   icon: Icons.photo_library_outlined,
///   title: 'No photos yet',
///   description: 'Upload your first photo to get started',
///   actionLabel: 'Upload Photo',
///   onAction: () {},
/// )
///
/// DSEmptyState(
///   icon: Icons.search_off,
///   title: 'No results',
///   description: 'Try a different search term',
/// )
/// ```
class DSEmptyState extends StatelessWidget {
  const DSEmptyState({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.iconSize = 64,
    this.padding = const EdgeInsets.all(32),
  });

  final IconData? icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
