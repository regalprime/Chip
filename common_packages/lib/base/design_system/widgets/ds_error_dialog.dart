import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows an error dialog with copyable message and logs to terminal.
///
/// Usage:
/// ```dart
/// DSErrorDialog.show(context, message: 'Failed to load data: ...');
/// ```
class DSErrorDialog {
  DSErrorDialog._();

  static void show(BuildContext context, {required String message}) {
    // Log to terminal
    dev.log('ERROR: $message', name: 'APP_ERROR');

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error, size: 24),
              const SizedBox(width: 8),
              const Text('Loi'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: SelectableText(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: message));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Da copy loi'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Dong'),
            ),
          ],
        );
      },
    );
  }
}
