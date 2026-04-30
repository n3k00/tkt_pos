import 'package:flutter/material.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/dimens.dart';

class AppTextStyles {
  // Section/page title
  static TextStyle sectionTitle(BuildContext context) =>
      (Theme.of(context).textTheme.titleLarge ??
              const TextStyle(fontSize: Dimens.fontSizeStat))
          .copyWith(
    fontWeight: FontWeight.w700,
    color: AppColor.textDefault,
  );

  // Subtitle used for cards/sections inside a page
  static TextStyle subtitle(
    TextTheme textTheme, {
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    final base = textTheme.titleMedium ??
        const TextStyle(fontSize: Dimens.fontSizeSubtitle);
    return base.copyWith(
      fontWeight: fontWeight,
      color: color ?? AppColor.textPrimary,
    );
  }

  // Default body text with optional emphasis overrides
  static TextStyle body(
    TextTheme textTheme, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    final base =
        textTheme.bodyMedium ?? const TextStyle(fontSize: Dimens.fontSizeBody);
    return base.copyWith(
      color: color ?? AppColor.textSecondary,
      fontWeight: fontWeight,
    );
  }

  // Small supporting labels/captions
  static TextStyle caption(
    TextTheme textTheme, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    final base =
        textTheme.bodySmall ?? const TextStyle(fontSize: Dimens.fontSizeCaption);
    return base.copyWith(
      color: color ?? AppColor.textSecondary,
      fontWeight: fontWeight,
    );
  }

  // Table header
  static const TextStyle tableHeader = TextStyle(
    color: AppColor.textDefault,
    fontWeight: FontWeight.w600,
  );

  // Table cell
  static const TextStyle tableCell = TextStyle(
    color: AppColor.textDefault,
  );
}

class AppTableStyles {
  // Consistent zebra coloring for DataRow backgrounds across the app
  static WidgetStateProperty<Color?> zebra(
          int rowIndex, {
          Color even = AppColor.surfaceBackground,
          Color odd = AppColor.white,
        }) =>
      WidgetStatePropertyAll(rowIndex.isEven ? even : odd);
}
