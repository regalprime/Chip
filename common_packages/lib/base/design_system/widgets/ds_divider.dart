import 'package:common_packages/constants/app_colors_extension.dart';
import 'package:flutter/material.dart';

/// A themed divider with optional label.
///
/// Usage:
/// ```dart
/// DSDivider()
///
/// DSDivider(label: 'or')
///
/// DSDivider(indent: 16, endIndent: 16)
/// ```
class DSDivider extends StatelessWidget {
  const DSDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    this.height = 1,
    this.label,
    this.color,
  });

  /// Creates a divider with a centered text label (e.g., "or", "section").
  const DSDivider.withLabel({
    super.key,
    required this.label,
    this.color,
  })  : indent = 0,
        endIndent = 0,
        height = 1;

  final double indent;
  final double endIndent;
  final double height;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>();
    final dividerColor = color ?? appColors?.divider ?? theme.dividerColor;

    if (label == null) {
      return Divider(
        height: height,
        indent: indent,
        endIndent: endIndent,
        color: dividerColor,
      );
    }

    return Row(
      children: [
        Expanded(
          child: Divider(
            height: height,
            indent: indent,
            color: dividerColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            height: height,
            endIndent: endIndent,
            color: dividerColor,
          ),
        ),
      ],
    );
  }
}
