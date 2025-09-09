// lib/theme/colors.dart
import 'package:flutter/material.dart';

class AppColor {
  // Primary (soft wellness green like the screenshot)
  static const Color primary = Color(0xFF3FAE73);

  // Variants (light to dark)
  static const Color primaryLight = Color(0xFFE6F3EC); // pale mint
  static const Color primaryDark = Color(0xFF1F7A55); // deep green

  // Accent / Secondary greens
  static const Color secondary = Color(0xFF7CCBA2); // soft green
  static const Color accent = Color(0xFFA7E3C3); // mint highlight

  // Text Colors (green-friendly neutrals)
  static const Color textPrimary = Color(0xFF1B4332); // deep forest
  static const Color textSecondary = Color(0xFF52796F); // desaturated

  // Backgrounds (warm, slightly greenish off-white)
  static const Color background = Color(0xFFF3F5EE);
  static const Color card = Color(0xFFFFFFFF);
  static const Color surfaceBackground = Color(0xFFF6F8F2);

  // Border / Line
  static const Color border = Color(0xFFE5ECE5);

  // Status
  static const Color error = Color(0xFFEF5350);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF6C26B);

  // Common neutrals
  static const Color textDefault = Colors.black87;
  static const Color white = Colors.white;
  static const Color disabled = Color(0xFFBDBDBD);

  // Drawer selection
  static const Color drawerItemSelectedBackground = Color(0xFFEFF7F2);
  static const Color drawerItemSelectedIconText = AppColor.primary;
}
