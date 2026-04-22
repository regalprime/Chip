import 'package:flutter/material.dart';

/// Helper class to show themed bottom sheets.
///
/// Usage:
/// ```dart
/// DSBottomSheet.show(
///   context: context,
///   title: 'Choose an option',
///   child: Column(
///     children: [
///       ListTile(title: Text('Option 1'), onTap: () {}),
///       ListTile(title: Text('Option 2'), onTap: () {}),
///     ],
///   ),
/// );
///
/// // Full-screen modal for forms
/// DSBottomSheet.showFullScreen(
///   context: context,
///   title: 'Add new item',
///   child: MyFormWidget(),
/// );
/// ```
class DSBottomSheet {
  DSBottomSheet._();

  /// Shows a bottom sheet with optional title, drag handle, and close button.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showDragHandle = true,
    bool showCloseButton = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useSafeArea = true,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: useSafeArea,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _DSBottomSheetContent(
        title: title,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        padding: padding,
        child: child,
      ),
    );
  }

  /// Shows a full-screen-like bottom sheet (takes most of the screen height).
  static Future<T?> showFullScreen<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showCloseButton = true,
    bool isDismissible = true,
    bool useSafeArea = true,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      useSafeArea: useSafeArea,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => _DSBottomSheetContent(
          title: title,
          showDragHandle: true,
          showCloseButton: showCloseButton,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _DSBottomSheetContent extends StatelessWidget {
  const _DSBottomSheetContent({
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.showCloseButton = false,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });

  final Widget child;
  final String? title;
  final bool showDragHandle;
  final bool showCloseButton;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDragHandle)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        if (title != null || showCloseButton)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: title != null
                      ? Text(title!, style: theme.textTheme.headlineLarge)
                      : const SizedBox.shrink(),
                ),
                if (showCloseButton)
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
        Flexible(
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ],
    );
  }
}
