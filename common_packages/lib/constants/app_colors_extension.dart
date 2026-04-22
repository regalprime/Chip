import 'package:flutter/material.dart';

/// Custom colors that don't fit into [ColorScheme].
/// Access via: Theme.of(context).extension<AppColorsExtension>()
/// Or shortcut: context.appColors (see context_extension.dart)
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color textPrimary;
  final Color textSecondary;
  final Color card;
  final Color divider;
  final Color success;
  final Color warning;
  final Color info;

  const AppColorsExtension({
    required this.textPrimary,
    required this.textSecondary,
    required this.card,
    required this.divider,
    required this.success,
    required this.warning,
    required this.info,
  });

  @override
  AppColorsExtension copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? card,
    Color? divider,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppColorsExtension(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      card: card ?? this.card,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppColorsExtension lerp(covariant AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      card: Color.lerp(card, other.card, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
