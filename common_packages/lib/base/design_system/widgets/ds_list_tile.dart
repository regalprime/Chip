import 'package:common_packages/constants/app_colors_extension.dart';
import 'package:flutter/material.dart';

/// A themed list tile for settings rows, menu items, etc.
/// Replaces the existing RowTile pattern with a more flexible component.
///
/// Usage:
/// ```dart
/// DSListTile(
///   icon: Icons.person_outline,
///   title: 'Profile',
///   onTap: () {},
/// )
///
/// DSListTile(
///   icon: Icons.notifications_outlined,
///   title: 'Notifications',
///   subtitle: '3 new messages',
///   trailing: DSBadge(label: '3'),
///   onTap: () {},
/// )
///
/// DSListTile(
///   icon: Icons.dark_mode_outlined,
///   title: 'Dark Mode',
///   trailing: Switch(value: true, onChanged: (_) {}),
///   showDivider: true,
/// )
/// ```
class DSListTile extends StatelessWidget {
  const DSListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.showArrow = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool showArrow;
  final EdgeInsetsGeometry padding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>();
    final contentColor = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withOpacity(0.4);

    return Column(
      children: [
        InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: padding,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 22,
                    color: iconColor ?? contentColor,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: contentColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (showArrow && onTap != null)
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: icon != null ? 50 : 16,
            color: appColors?.divider ?? theme.dividerColor,
          ),
      ],
    );
  }
}
