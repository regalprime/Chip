import 'package:flutter/material.dart';

/// Helper class to show themed dialogs.
///
/// Usage:
/// ```dart
/// // Alert dialog
/// DSDialog.alert(
///   context: context,
///   title: 'Error',
///   message: 'Something went wrong',
/// );
///
/// // Confirm dialog
/// final confirmed = await DSDialog.confirm(
///   context: context,
///   title: 'Delete item?',
///   message: 'This action cannot be undone.',
///   confirmLabel: 'Delete',
///   isDestructive: true,
/// );
/// if (confirmed) { ... }
///
/// // Custom dialog
/// DSDialog.custom(
///   context: context,
///   title: 'Choose option',
///   child: Column(children: [...]),
///   actions: [
///     DSDialogAction(label: 'Cancel', onPressed: () => Navigator.pop(context)),
///     DSDialogAction(label: 'OK', onPressed: () => Navigator.pop(context, true)),
///   ],
/// );
/// ```
class DSDialog {
  DSDialog._();

  /// Shows a simple alert dialog with a single OK button.
  static Future<void> alert({
    required BuildContext context,
    required String title,
    String? message,
    String okLabel = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: message != null ? Text(message) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(okLabel),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog and returns `true` if confirmed.
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(title),
          content: message != null ? Text(message) : null,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: isDestructive
                  ? TextButton.styleFrom(foregroundColor: colorScheme.error)
                  : null,
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Shows a custom dialog with arbitrary content and actions.
  static Future<T?> custom<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    List<DSDialogAction> actions = const [],
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: child,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: actions
            .map((a) => TextButton(
                  onPressed: a.onPressed,
                  style: a.isDestructive
                      ? TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(ctx).colorScheme.error)
                      : null,
                  child: Text(a.label),
                ))
            .toList(),
      ),
    );
  }
}

class DSDialogAction {
  const DSDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
}
