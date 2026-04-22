import 'package:common_packages/constants/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:common_packages/base/languages/l10n/gen/app_localizations.dart';

// ── Localization ──
extension LocalizationExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

// ── Theme shortcuts ──
extension ThemeExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  // ColorScheme
  ColorScheme get colorScheme => theme.colorScheme;
  Color get primaryColor => colorScheme.primary;
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get errorColor => colorScheme.error;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // Custom colors (ThemeExtension)
  AppColorsExtension get appColors => theme.extension<AppColorsExtension>()!;

  // TextTheme
  TextTheme get textTheme => theme.textTheme;
  TextStyle? get bodySmall => textTheme.bodySmall;
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get headlineLarge => textTheme.headlineLarge;
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  TextStyle? get headlineSmall => textTheme.headlineSmall;
}
