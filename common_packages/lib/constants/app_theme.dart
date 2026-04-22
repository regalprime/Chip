import 'package:common_packages/constants/app_colors.dart';
import 'package:common_packages/constants/app_colors_extension.dart';
import 'package:common_packages/constants/app_font.dart';
import 'package:common_packages/constants/app_size.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  // ────────────────────────────────────────────
  // LIGHT THEME
  // ────────────────────────────────────────────
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.brand,
      onPrimary: Colors.white,
      secondary: AppColors.brandDark,
      onSecondary: Colors.white,
      tertiary: AppColors.brandSurface,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
    );

    const appColorsExtension = AppColorsExtension(
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      card: AppColors.lightCard,
      divider: AppColors.lightDivider,
      success: AppColors.success,
      warning: AppColors.warning,
      info: AppColors.info,
    );

    return _buildTheme(colorScheme, appColorsExtension, Brightness.light);
  }

  // ────────────────────────────────────────────
  // DARK THEME
  // ────────────────────────────────────────────
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.brand,
      onPrimary: Colors.white,
      secondary: AppColors.brandLight,
      onSecondary: Colors.white,
      tertiary: AppColors.brandDark,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
    );

    const appColorsExtension = AppColorsExtension(
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      card: AppColors.darkCard,
      divider: AppColors.darkDivider,
      success: AppColors.success,
      warning: AppColors.warning,
      info: AppColors.info,
    );

    return _buildTheme(colorScheme, appColorsExtension, Brightness.dark);
  }

  // ────────────────────────────────────────────
  // SHARED BUILDER
  // ────────────────────────────────────────────
  static ThemeData _buildTheme(
    ColorScheme colorScheme,
    AppColorsExtension appColorsExtension,
    Brightness brightness,
  ) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFont.appFontFamilyName,
      colorScheme: colorScheme,
      brightness: brightness,

      scaffoldBackgroundColor:
          isLight ? AppColors.lightBackground : AppColors.darkBackground,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor:
            isLight ? AppColors.lightBackground : AppColors.darkBackground,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppFont.appFontFamilyName,
          fontSize: AppSize.s20AppBarTxt,
          color: colorScheme.primary,
          fontWeight: AppSize.w600,
        ),
      ),

      // ── Text ──
      textTheme: TextTheme(
        bodySmall: TextStyle(
          color: colorScheme.onSurface,
          fontSize: AppSize.s12Fnt,
          fontFamily: AppFont.appFontFamilyName,
        ),
        bodyMedium: TextStyle(
          color: colorScheme.onSurface,
          fontSize: AppSize.s14Fnt,
          fontFamily: AppFont.appFontFamilyName,
        ),
        bodyLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: AppSize.s16Fnt,
          fontFamily: AppFont.appFontFamilyName,
        ),
        headlineLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: AppSize.s20Fnt,
          fontFamily: AppFont.appFontFamilyName,
          fontWeight: AppSize.w700,
        ),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: appColorsExtension.divider,
        thickness: 1,
      ),

      // ── Card ──
      cardTheme: CardThemeData(
        color: appColorsExtension.card,
        elevation: isLight ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s16Rad),
        ),
      ),

      // ── ListTile ──
      listTileTheme: ListTileThemeData(
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurface,
      ),

      // ── FilledButton ──
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(colorScheme.primary),
          foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontSize: AppSize.s14Fnt,
              fontFamily: AppFont.appFontFamilyName,
              fontWeight: AppSize.w500,
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              vertical: AppSize.s16Pad,
              horizontal: AppSize.s20Pad,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSize.s8Rad),
            ),
          ),
        ),
      ),

      // ── Switch ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(colorScheme.primary),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withOpacity(0.4);
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // ── Icon ──
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: AppSize.s24Ico,
      ),

      // ── Extensions ──
      extensions: [appColorsExtension],
    );
  }
}
