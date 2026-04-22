import 'package:flutter/material.dart';

/// Badge variant determines the color scheme.
enum DSBadgeVariant { primary, success, warning, error, neutral }

/// A small badge/chip component for labels, tags, and status indicators.
///
/// Usage:
/// ```dart
/// DSBadge(label: 'New')
///
/// DSBadge(
///   label: 'Active',
///   variant: DSBadgeVariant.success,
///   icon: Icons.check_circle_outline,
/// )
///
/// DSBadge(
///   label: 'Flutter',
///   onDelete: () {},
/// )
///
/// DSBadge.dot(variant: DSBadgeVariant.error)
/// ```
class DSBadge extends StatelessWidget {
  const DSBadge({
    super.key,
    required this.label,
    this.variant = DSBadgeVariant.primary,
    this.icon,
    this.onTap,
    this.onDelete,
    this.size = DSBadgeSize.medium,
  }) : _isDot = false;

  const DSBadge.dot({
    super.key,
    this.variant = DSBadgeVariant.primary,
    this.size = DSBadgeSize.medium,
  })  : label = '',
        icon = null,
        onTap = null,
        onDelete = null,
        _isDot = true;

  final String label;
  final DSBadgeVariant variant;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final DSBadgeSize size;
  final bool _isDot;

  Color _backgroundColor(ColorScheme cs) {
    switch (variant) {
      case DSBadgeVariant.primary:
        return cs.primaryContainer;
      case DSBadgeVariant.success:
        return const Color(0xFFE8F5E9);
      case DSBadgeVariant.warning:
        return const Color(0xFFFFF3E0);
      case DSBadgeVariant.error:
        return cs.errorContainer;
      case DSBadgeVariant.neutral:
        return cs.surfaceContainerHighest;
    }
  }

  Color _foregroundColor(ColorScheme cs) {
    switch (variant) {
      case DSBadgeVariant.primary:
        return cs.onPrimaryContainer;
      case DSBadgeVariant.success:
        return const Color(0xFF2E7D32);
      case DSBadgeVariant.warning:
        return const Color(0xFFE65100);
      case DSBadgeVariant.error:
        return cs.onErrorContainer;
      case DSBadgeVariant.neutral:
        return cs.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = _backgroundColor(cs);
    final fg = _foregroundColor(cs);

    if (_isDot) {
      final dotSize = size == DSBadgeSize.small ? 8.0 : 10.0;
      return Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: fg,
          shape: BoxShape.circle,
        ),
      );
    }

    final fontSize = size == DSBadgeSize.small ? 10.0 : 12.0;
    final hPad = size == DSBadgeSize.small ? 6.0 : 10.0;
    final vPad = size == DSBadgeSize.small ? 2.0 : 4.0;
    final iconSize = size == DSBadgeSize.small ? 12.0 : 14.0;

    Widget chip = Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close, size: iconSize, color: fg),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      chip = GestureDetector(onTap: onTap, child: chip);
    }

    return chip;
  }
}

enum DSBadgeSize { small, medium }
