// lib/theme/colors.dart
import 'package:flutter/material.dart';

class AppColor {
  // Primary Base Green
  static const Color primary = Color(0xFF4CAF50); // Material Green 500

  // Variants (light to dark)
  static const Color primaryLight = Color(0xFFC8E6C9); // Green 100
  static const Color primaryDark = Color(0xFF2E7D32); // Green 800

  // Accent / Secondary colors
  static const Color secondary = Color(0xFF81C784); // Green 300
  static const Color accent = Color(0xFF66BB6A); // Green 400

  // Text Colors
  static const Color textPrimary = Color(0xFF1B5E20);
  static const Color textSecondary = Color(0xFF4E944F);

  // Background
  static const Color background = Color(0xFFF1F8E9); // Light Green BG
  static const Color card = Color(0xFFE8F5E9);

  // Border / Line
  static const Color border = Color(0xFFB2DFDB);

  // Error
  static const Color error = Colors.redAccent;

  // Success
  static const Color success = Color(0xFF2E7D32);

  // Warning
  static const Color warning = Color(0xFFFFA726);

  // Disabled
  static const Color disabled = Color(0xFFBDBDBD);

  static const Color drawerItemSelectedBackground = Color(
    0xFFE8F5E9,
  ); // Same as 'card' or a bit lighter than primaryLight
  // Or maybe AppColor.secondary.withOpacity(0.2);
  static const Color drawerItemSelectedIconText = AppColor.primary;
}
