// lib/theme/colors.dart
import 'package:flutter/material.dart';

class AppColor {
  // Primary (soft indigo/blue to match the reference UI)
  static const Color primary = Color(0xFF6C7FF2); // Indigo 400–500 vibe

  // Variants (light to dark)
  static const Color primaryLight = Color(0xFFDDE2FF); // very light periwinkle
  static const Color primaryDark = Color(0xFF3D4ADE); // deeper indigo

  // Accent / Secondary
  static const Color secondary = Color(0xFF8EA1F8); // lighter indigo
  static const Color accent = Color(0xFF62D5F5); // cyan accent for highlights

  // Text Colors (neutral darks for readability on light backgrounds)
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF475569); // slate-600

  // Backgrounds
  static const Color background = Color(0xFFEFF3FF); // soft bluish background
  static const Color card = Color(0xFFFFFFFF); // white cards
  // Neutral surface used by some pages (e.g., inventory)
  static const Color surfaceBackground = Color(0xFFF5F7FC); // subtle panel bg

  // Border / Line
  static const Color border = Color(0xFFE5E7EB); // light grey border

  // Status
  static const Color error = Color(0xFFFF5A5A);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);

  // Common neutrals
  static const Color textDefault = Colors.black87;
  static const Color white = Colors.white;
  static const Color disabled = Color(0xFFBDBDBD);

  // Drawer selection
  static const Color drawerItemSelectedBackground = Color(0xFFF0F3FF);
  static const Color drawerItemSelectedIconText = AppColor.primary;
}
