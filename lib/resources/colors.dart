// lib/theme/colors.dart
import 'package:flutter/material.dart';

class AppColor {
  // Brand primaries
  static const Color primary = Color(0xFF1EA97C);
  static const Color primaryDark = Color(0xFF157A58);
  static const Color primaryLight = Color(0xFFD8F1E6);

  // Accent / highlights
  static const Color accent = Color(0xFFFF9C00);
  static const Color secondary = Color(0xFF27AE60);

  // Neutrals & surfaces
  static const Color background = Color(0xFFEDEFF2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = surface;
  static const Color surfaceBackground = Color(0xFFF8FAFB);
  static const Color border = Color(0xFFE0E4E9);

  // Text colors
  static const Color textPrimary = Color(0xFF1B1D21);
  static const Color textSecondary = Color(0xFF6A717B);
  static const Color textMuted = Color(0xFF9AA0AA);
  static const Color textDefault = textPrimary;

  // Status colors
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFF14646);
  static const Color info = Color(0xFF3A7BDF);
  static const Color warning = Color(0xFFFFC857);

  // Common neutrals
  static const Color white = Colors.white;
  static const Color disabled = Color(0xFFB7BEC7);
  static const Color transparent = Colors.transparent;

  // Drawer / navigation
  static const Color drawerItemSelectedBackground = Color(0xFFE6F4EF);
  static const Color drawerItemSelectedIconText = primary;
}
