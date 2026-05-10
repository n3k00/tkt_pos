import 'package:flutter/services.dart';

class MoneyInput {
  static final List<TextInputFormatter> inputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
  ];

  static String normalize(String value) {
    return value.trim().replaceAll(',', '');
  }

  static int? parseKyat(String value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return null;
    if (!RegExp(r'^\d+$').hasMatch(normalized)) return null;
    return int.tryParse(normalized);
  }

  static String? validateRequiredKyat(String? value) {
    final normalized = normalize(value ?? '');
    if (normalized.isEmpty) return 'Amount is required';
    if (!RegExp(r'^\d+$').hasMatch(normalized)) {
      return 'Enter whole kyat only';
    }
    return null;
  }

  static String? validateOptionalKyat(String? value) {
    final normalized = normalize(value ?? '');
    if (normalized.isEmpty) return null;
    if (!RegExp(r'^\d+$').hasMatch(normalized)) {
      return 'Enter whole kyat only';
    }
    return null;
  }

  static double parseRequiredKyatAsDouble(String value) {
    return parseKyat(value)!.toDouble();
  }

  static double parseOptionalKyatAsDouble(String value) {
    return (parseKyat(value) ?? 0).toDouble();
  }

  static String formatInitial(double value) {
    return value.toStringAsFixed(0);
  }
}
