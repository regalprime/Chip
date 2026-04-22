import 'package:flutter/material.dart';

/// Button variant determines the visual style.
enum DSButtonVariant { filled, outlined, ghost, text, danger }

/// Button size determines padding and font size.
enum DSButtonSize { small, medium, large }

/// A unified button component for the entire app.
///
/// Usage:
/// ```dart
/// DSButton(
///   label: 'Save',
///   onPressed: () {},
/// )
///
/// DSButton(
///   label: 'Delete',
///   variant: DSButtonVariant.danger,
///   icon: Icons.delete,
///   onPressed: () {},
/// )
///
/// DSButton(
///   label: 'Saving...',
///   isLoading: true,
///   onPressed: null,
/// )
/// ```
class DSButton extends StatelessWidget {
  const DSButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DSButtonVariant.filled,
    this.size = DSButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final DSButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool expand;

  bool get _isDisabled => onPressed == null || isLoading;

  EdgeInsets get _padding {
    switch (size) {
      case DSButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case DSButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
      case DSButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 18);
    }
  }

  double get _fontSize {
    switch (size) {
      case DSButtonSize.small:
        return 12;
      case DSButtonSize.medium:
        return 14;
      case DSButtonSize.large:
        return 16;
    }
  }

  double get _iconSize {
    switch (size) {
      case DSButtonSize.small:
        return 16;
      case DSButtonSize.medium:
        return 20;
      case DSButtonSize.large:
        return 22;
    }
  }

  double get _loaderSize {
    switch (size) {
      case DSButtonSize.small:
        return 14;
      case DSButtonSize.medium:
        return 18;
      case DSButtonSize.large:
        return 20;
    }
  }

  BorderRadius get _borderRadius => BorderRadius.circular(
        size == DSButtonSize.small ? 8 : 12,
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: _loaderSize,
            height: _loaderSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foregroundColor(colorScheme),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: _iconSize),
          const SizedBox(width: 8),
        ],
        Text(label),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: _iconSize),
        ],
      ],
    );

    final textStyle = TextStyle(
      fontSize: _fontSize,
      fontWeight: FontWeight.w600,
    );

    final shape = RoundedRectangleBorder(borderRadius: _borderRadius);

    switch (variant) {
      case DSButtonVariant.filled:
        return FilledButton(
          onPressed: _isDisabled ? null : onPressed,
          style: FilledButton.styleFrom(
            padding: _padding,
            textStyle: textStyle,
            shape: shape,
            minimumSize: expand ? const Size(double.infinity, 0) : null,
          ),
          child: child,
        );

      case DSButtonVariant.outlined:
        return OutlinedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: _padding,
            textStyle: textStyle,
            shape: shape,
            side: BorderSide(
              color: _isDisabled
                  ? colorScheme.outline.withOpacity(0.3)
                  : colorScheme.outline,
            ),
            minimumSize: expand ? const Size(double.infinity, 0) : null,
          ),
          child: child,
        );

      case DSButtonVariant.ghost:
        return TextButton(
          onPressed: _isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            padding: _padding,
            textStyle: textStyle,
            shape: shape,
            minimumSize: expand ? const Size(double.infinity, 0) : null,
          ),
          child: child,
        );

      case DSButtonVariant.text:
        return TextButton(
          onPressed: _isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            padding: _padding,
            textStyle: textStyle,
            minimumSize: expand ? const Size(double.infinity, 0) : null,
          ),
          child: child,
        );

      case DSButtonVariant.danger:
        return FilledButton(
          onPressed: _isDisabled ? null : onPressed,
          style: FilledButton.styleFrom(
            padding: _padding,
            textStyle: textStyle,
            shape: shape,
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            minimumSize: expand ? const Size(double.infinity, 0) : null,
          ),
          child: child,
        );
    }
  }

  Color _foregroundColor(ColorScheme colorScheme) {
    switch (variant) {
      case DSButtonVariant.filled:
        return colorScheme.onPrimary;
      case DSButtonVariant.danger:
        return colorScheme.onError;
      case DSButtonVariant.outlined:
      case DSButtonVariant.ghost:
      case DSButtonVariant.text:
        return colorScheme.primary;
    }
  }
}

/// Icon-only button for toolbars, app bars, etc.
///
/// Usage:
/// ```dart
/// DSIconButton(
///   icon: Icons.edit,
///   onPressed: () {},
/// )
/// ```
class DSIconButton extends StatelessWidget {
  const DSIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 24,
    this.color,
    this.tooltip,
    this.badge,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final String? tooltip;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onPressed,
      tooltip: tooltip,
    );

    if (badge != null && badge! > 0) {
      iconWidget = Badge(
        label: Text(badge.toString()),
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}
