import 'package:flutter/material.dart';

/// Snackbar variant for different message types.
enum DSSnackbarVariant { info, success, warning, error }

/// Helper class to show themed snackbars.
///
/// Usage:
/// ```dart
/// DSSnackbar.show(context, message: 'Item saved successfully');
///
/// DSSnackbar.success(context, message: 'Profile updated!');
///
/// DSSnackbar.error(context, message: 'Failed to load data');
///
/// DSSnackbar.show(
///   context,
///   message: 'Item deleted',
///   actionLabel: 'Undo',
///   onAction: () { /* undo logic */ },
/// );
/// ```
class DSSnackbar {
  DSSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    DSSnackbarVariant variant = DSSnackbarVariant.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color foregroundColor;
    IconData? icon;

    switch (variant) {
      case DSSnackbarVariant.info:
        backgroundColor = colorScheme.inverseSurface;
        foregroundColor = colorScheme.onInverseSurface;
        icon = null;
      case DSSnackbarVariant.success:
        backgroundColor = const Color(0xFF2E7D32);
        foregroundColor = Colors.white;
        icon = Icons.check_circle_outline;
      case DSSnackbarVariant.warning:
        backgroundColor = const Color(0xFFE65100);
        foregroundColor = Colors.white;
        icon = Icons.warning_amber_rounded;
      case DSSnackbarVariant.error:
        backgroundColor = colorScheme.error;
        foregroundColor = colorScheme.onError;
        icon = Icons.error_outline;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: foregroundColor, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: foregroundColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: foregroundColor,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  static void success(BuildContext context, {required String message}) {
    show(context, message: message, variant: DSSnackbarVariant.success);
  }

  static void error(BuildContext context, {required String message}) {
    show(context, message: message, variant: DSSnackbarVariant.error);
  }

  static void warning(BuildContext context, {required String message}) {
    show(context, message: message, variant: DSSnackbarVariant.warning);
  }

  static void info(BuildContext context, {required String message}) {
    show(context, message: message, variant: DSSnackbarVariant.info);
  }
}
