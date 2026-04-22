import 'package:flutter/material.dart';

/// Raw color palette for the app.
/// These are only used inside [AppTheme] to build ThemeData.
/// Widgets should NEVER import this file directly — use Theme.of(context) instead.
abstract final class AppColors {
  // ── Brand ──
  static const Color brand = Color(0xFFD32F2F);
  static const Color brandDark = Color(0xFFB71C1C);
  static const Color brandLight = Color(0xFFEF5350);
  static const Color brandSurface = Color(0xFFFFCDD2);

  // ── Light mode ──
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightTextPrimary = Color(0xFF1C1C1E);
  static const Color lightTextSecondary = Color(0xFF6E6E73);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightCard = Color(0xFFFFFFFF);

  // ── Dark mode ──
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFAEAEB2);
  static const Color darkDivider = Color(0xFF2C2C2E);
  static const Color darkCard = Color(0xFF1E1E1E);

  // ── Semantic ──
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);
}
