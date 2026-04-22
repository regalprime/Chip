import 'package:flutter/material.dart';

/// A toggle switch with label and optional description.
///
/// Usage:
/// ```dart
/// DSSwitch(
///   value: _darkMode,
///   label: 'Dark Mode',
///   onChanged: (v) => setState(() => _darkMode = v),
/// )
///
/// DSSwitch(
///   value: _notifications,
///   label: 'Push Notifications',
///   description: 'Get notified when someone sends you a message',
///   icon: Icons.notifications_outlined,
///   onChanged: (v) {},
/// )
/// ```
class DSSwitch extends StatelessWidget {
  const DSSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.icon,
    this.enabled = true,
    this.showDivider = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? description;
  final IconData? icon;
  final bool enabled;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      );
    }

    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: enabled && onChanged != null
              ? () => onChanged!(!value)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 22,
                    color: enabled
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: enabled
                              ? null
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: theme.extension<dynamic>() != null
                ? theme.dividerColor
                : theme.dividerColor,
          ),
      ],
    );
  }
}
